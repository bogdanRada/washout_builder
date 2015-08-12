# encoding:utf-8

require 'spec_helper'

describe WashoutBuilder do
  before(:each) do
    WashOut::Engine.config.wash_out[:wsdl_style] = 'rpc'
    WashOut::Engine.config.wash_out[:parser] = :nokogiri
    WashOut::Engine.config.wash_out[:catch_xml_errors] = true
    WashOut::Engine.config.wash_out[:camelize_wsdl] = 'lower'
  end

  let :nori do
    Nori.new(
      strip_namespaces: true,
      advanced_typecasting: true,
      convert_tags_to: ->(x) { x.snakecase.to_sym }
    )
  end

  def savon(method, message = {}, &block)
    message = { value: message } unless message.is_a?(Hash)

    savon_client = Savon::Client.new(log: false, wsdl: 'http://app/api/wsdl', &block)
    result = savon_client.call(method, message: message)
    result.respond_to?(:to_hash) ? result.to_hash : result
  end

  def savon!(method, message = {}, &block)
    message = { value: message } unless message.is_a?(Hash)

    savon_client = Savon::Client.new(log: true, wsdl: 'http://app/api/wsdl', &block)
    result = savon_client.call(method, message: message)
    result.respond_to?(:to_hash) ? result.to_hash : result
  end

  describe 'Module' do
    it 'includes' do
      expect do
        lambda do
          mock_controller do
            # nothing
          end
        end
      end.to_not raise_exception
    end

    it 'allows definition of a simple action' do
      expect do
        lambda do
          mock_controller do
            soap_action 'answer', args: nil, return: :integer
          end
        end
      end.to_not raise_exception
    end
  end

  describe 'WSDL' do
    let :wsdl do
      mock_controller do
        soap_action :result, args: nil, return: :int

        soap_action 'getArea', args: {
          circle: [{
            center: { x: [:integer], y: :integer },
            radius: :double
          }] },
                               return: { area: :double }
        soap_action 'rocky', args: { circle1: { x: :integer } },
                             return: { circle2: { y: :integer } }
      end

      HTTPI.get('http://app/api/wsdl').body
    end

    let :xml do
      nori.parse wsdl
    end

    it 'lists operations' do
      operations = xml[:definitions][:binding][:operation]
      expect(operations).to be_a_kind_of(Array)

      expect(operations.map { |e| e[:'@name'] }.sort).to eq %w(Result getArea rocky).sort
    end

    it 'defines complex types' do
      expect(wsdl.include?('<xsd:complexType name="Circle1">')).to eq true
    end

    it 'defines arrays' do
      x = xml[:definitions][:types][:schema][:complex_type]
          .find { |inneer_x| inneer_x[:'@name'] == 'Center' }[:sequence][:element]
          .find { |inneer_x| inneer_x[:'@name'] == 'X' }

      expect(x[:'@min_occurs']).to eq('0')
      expect(x[:'@max_occurs']).to eq('unbounded')
    end
  end

  describe 'Dispatcher' do
    context 'simple actions' do
      it 'accepts requests with no HTTP header' do
        mock_controller do
          soap_action 'answer', args: nil, return: :int
          def answer
            render soap: '42'
          end
        end

        request = <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="false" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <tns:answer>
              <value>42</value>
            </tns:answer>
          </env:Body>
          </env:Envelope>
        XML

        expect(HTTPI.post('http://app/api/action', request).body).to eq(<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="false">
  <soap:Body>
    <tns:answerResponse>
      <Value xsi:type="xsd:int">42</Value>
    </tns:answerResponse>
  </soap:Body>
</soap:Envelope>
        XML
                                                                       )
      end

      it 'accept no parameters' do
        mock_controller do
          soap_action 'answer', args: nil, return: :int
          def answer
            render soap: '42'
          end
        end

        expect(savon(:answer)[:answer_response][:value]
              ).to eq '42'
      end

      it 'accept insufficient parameters' do
        mock_controller do
          soap_action 'answer', args: { a: :integer }, return: :integer
          def answer
            render soap: '42'
          end
        end

        expect(savon(:answer)[:answer_response][:value]
              ).to eq '42'
      end

      it 'accept empty parameter' do
        mock_controller do
          soap_action 'answer', args: { a: :string }, return: { a: :string }
          def answer
            render soap: { a: params[:a] }
          end
        end
        expect(savon(:answer, a: '')[:answer_response][:a][:'@xsi:type']).to eq('xsd:string')
      end

      it 'accept one parameter' do
        mock_controller do
          soap_action 'checkAnswer', args: :integer, return: :boolean, to: 'check_answer'
          def check_answer
            render soap: (params[:value] == 42)
          end
        end

        expect(savon(:check_answer, 42)[:check_answer_response][:value]).to eq true
        expect(savon(:check_answer, 13)[:check_answer_response][:value]).to eq false
      end

      it 'accept two parameters' do
        mock_controller do
          soap_action 'funky', args: { a: :integer, b: :string }, return: :string
          def funky
            render soap: ((params[:a] * 10).to_s + params[:b])
          end
        end

        expect(savon(:funky, a: 42, b: 'k')[:funky_response][:value]).to eq '420k'
      end
    end

    context 'complex actions' do
      it 'accept nested structures' do
        mock_controller do
          soap_action 'findArea', args: { circle: { center: { x: :integer,
                                                              y: :integer },
                                                    radius: :double } },
                                  return: { area: :double,
                                            distance_from_o: :double },
                                  to: :find_area
          def find_area
            circle = params[:circle]
            render soap: { area: Math::PI * circle[:radius]**2,
                           distance_from_o: Math.sqrt(circle[:center][:x]**2 + circle[:center][:y]**2) }
          end
        end

        message = { circle: { center: { x: 3, y: 4 },
                              radius: 5 } }

        expect(savon(:find_area, message)[:find_area_response]
              ).to eq(area: (Math::PI * 25).to_s, distance_from_o: (5.0).to_s)
      end

      it 'accept arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: {
                        rumbas: [:integer]
                      },
                      return: nil
          def rumba
            raise 'not ok' unless params == { 'rumbas' => [1, 2, 3] }
            render soap: nil
          end
        end

        savon(:rumba, rumbas: [1, 2, 3])
      end

      it 'accept empty arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: {
                        my_array: [:integer]
                      },
                      return: nil
          def rumba
            raise 'not ok' unless params == {}
            render soap: nil
          end
        end
        savon(:rumba, empty: [])
      end

      it 'accept nested empty arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: {
                        nested: { my_array: [:integer] }
                      },
                      return: nil
          def rumba
            raise 'not ok' unless params == { 'nested' => {} }
            render soap: nil
          end
        end
        savon(:rumba, nested: { my_array: [] })
      end

      it 'accept nested structures inside arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: {
                        rumbas: [{
                          zombies: :string,
                          puppies: :string
                        }]
                      },
                      return: nil
          def rumba
            raise 'not ok' unless params == { 'rumbas' => [
              { 'zombies' => 'suck', 'puppies' => 'rock' },
              { 'zombies' => 'slow', 'puppies' => 'fast' }
            ] }
            render soap: nil
          end
        end

        savon :rumba, rumbas: [
          { zombies: 'suck', puppies: 'rock' },
          { zombies: 'slow', puppies: 'fast' }
        ]
      end

      it 'respond with nested structures' do
        mock_controller do
          soap_action 'gogogo',
                      args: nil,
                      return: {
                        zoo: :string,
                        boo: { moo: :string, doo: :string }
                      }
          def gogogo
            render soap: {
              zoo: 'zoo',
              boo: { moo: 'moo', doo: 'doo' }
            }
          end
        end

        expect(savon(:gogogo)[:gogogo_response].deep_include?(zoo: 'zoo', boo: { moo: 'moo', doo: 'doo' })).to eq true

        expect(savon(:gogogo)[:gogogo_response][:boo][:'@xsi:type']).to eq('tns:Boo')
      end

      it 'respond with arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: nil,
                      return: [:integer]
          def rumba
            render soap: [1, 2, 3]
          end
        end

        expect(savon(:rumba)[:rumba_response]).to eq(value: %w(1 2 3))
      end

      it 'respond with complex structures inside arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: nil,
                      return: {
                        rumbas: [{ zombies: :string, puppies: :string }]
                      }
          def rumba
            render soap: { rumbas: [
              { zombies: 'suck1', puppies: 'rock1' },
              { zombies: 'suck2', puppies: 'rock2' }
            ]
            }
          end
        end

        expect(savon(:rumba)[:rumba_response].deep_include?(rumbas: [
          { zombies: 'suck1', puppies: 'rock1' },
          { zombies: 'suck2', puppies: 'rock2' }
        ])).to eq(true)

        expect(savon(:rumba)[:rumba_response][:rumbas][0][:'@xsi:type']).to eq('tns:Rumbas')
        expect(savon(:rumba)[:rumba_response][:rumbas][1][:'@xsi:type']).to eq('tns:Rumbas')
      end

      it 'respond with structs in structs in arrays' do
        mock_controller do
          soap_action 'rumba',
                      args: nil,
                      return: [{ rumbas: { zombies: :integer } }]

          def rumba
            render soap: [{ rumbas: { zombies: 100_000 } }, { rumbas: { zombies: 2 } }]
          end
        end

        expect(savon(:rumba)[:rumba_response].deep_include?(value: [
          {
            rumbas: {
              zombies: '100000'
            }
          },
          {
            rumbas: {
              zombies: '2'
            }
          }
        ])).to eq(true)

        expect(savon(:rumba)[:rumba_response][:value][0][:'@xsi:type']).to eq('tns:Value')
        expect(savon(:rumba)[:rumba_response][:value][1][:'@xsi:type']).to eq('tns:Value')

        expect(savon(:rumba)[:rumba_response][:value][0][:rumbas][:'@xsi:type']).to eq('tns:Rumbas')
        expect(savon(:rumba)[:rumba_response][:value][1][:rumbas][:'@xsi:type']).to eq('tns:Rumbas')
      end

      context 'with arrays missing' do
        it 'respond with simple definition' do
          mock_controller do
            soap_action 'rocknroll',
                        args: nil, return: { my_value: [:integer] }
            def rocknroll
              render soap: {}
            end
          end

          expect(savon(:rocknroll)[:rocknroll_response]).to be_nil
        end

        it 'respond with complext definition' do
          mock_controller do
            soap_action 'rocknroll',
                        args: nil, return: { my_value: [{ value: :integer }] }
            def rocknroll
              render soap: {}
            end
          end

          expect(savon(:rocknroll)[:rocknroll_response]).to be_nil
        end

        it 'respond with nested simple definition' do
          mock_controller do
            soap_action 'rocknroll',
                        args: nil, return: { my_value: { my_array: [{ value: :integer }] } }
            def rocknroll
              render soap: {}
            end
          end

          expect(savon(:rocknroll)[:rocknroll_response][:my_value][:'@xsi:type']).to eq('tns:MyValue')
        end

        it 'handles incomplete array response' do
          mock_controller do
            soap_action 'rocknroll',
                        args: nil, return: { my_value: [{ value: :string }] }
            def rocknroll
              render soap: { my_value: [nil] }
            end
          end

          expect { savon(:rocknroll) }.to_not raise_error
        end
      end
    end

    context 'types' do
      it 'recognize boolean' do
        mock_controller do
          soap_action 'true', args: :boolean, return: :nil
          def true
            raise 'not ok' unless params[:value] == true
            render soap: nil
          end

          soap_action 'false', args: :boolean, return: :nil
          def false
            raise 'not ok' unless params[:value] == false
            render soap: nil
          end
        end

        savon(:true, value: 'true')
        savon(:true, value: '1')
        savon(:false, value: 'false')
        savon(:false, value: '0')
      end

      it 'recognize dates' do
        mock_controller do
          soap_action 'date', args: :date, return: :nil
          def date
            raise Exception if params[:value].present? && params[:value] != Date.parse('2000-12-30')
            render soap: nil
          end
        end

        savon(:date, value: '2000-12-30')
        expect { savon(:date) }.not_to raise_exception
      end

      it 'recognize base64Binary' do
        mock_controller do
          soap_action 'base64', args: :base64Binary, return: :nil
          def base64
            raise Exception if params[:value].present? && params[:value] != 'test'
            render soap: nil
          end
        end

        savon(:base64, value: Base64.encode64('test'))
        expect { savon(:base64) }.not_to raise_exception
      end
    end

    context 'errors' do
      it 'raise for incorrect requests' do
        mock_controller do
          soap_action 'duty',
                      args: { bad: { a: :string, b: :string }, good: { a: :string, b: :string } },
                      return: nil
          def duty
            render soap: nil
          end
        end

        expect do
          savon(:duty, bad: 42, good: nil)
        end.to raise_exception(Savon::SOAPFault)
      end

      it 'raise for date in incorrect format' do
        mock_controller do
          soap_action 'date', args: :date, return: :nil
          def date
            render soap: nil
          end
        end
        expect do
          savon(:date, value: 'incorrect format')
        end.to raise_exception(Savon::SOAPFault)
      end

      it 'raise to report SOAP errors', fails: true do
        mock_controller do
          soap_action 'error', args: { need_error: :boolean }, return: nil
          def error
            raise self.class.const_get(:SOAPError), 'you wanted one' if params[:need_error]
            render soap: nil
          end
        end

        expect { savon(:error, need_error: false) }.not_to raise_exception
        expect { savon(:error, need_error: true) }.to raise_exception(Savon::SOAPFault)
      end

      it 'raise for manual throws' do
        mock_controller do
          soap_action 'error', args: nil, return: nil
          def error
            render_soap_error 'a message'
          end
        end

        expect { savon(:error) }.to raise_exception(Savon::SOAPFault)
      end

      it 'raise when response structure mismatches' do
        mock_controller do
          soap_action 'bad', args: :integer, return: {
            basic: :string,
            stallions: {
              stallion: [
                name: :string,
                wyldness: :integer
              ]
            }
          }
          def bad
            render soap: {
              basic: 'hi',
              stallions: [{ name: 'ted', wyldness: 11 }]
            }
          end

          soap_action 'bad2', args: :integer, return: {
            basic: :string,
            telephone_booths: [:string]
          }
          def bad2
            render soap: {
              basic: 'hihi',
              telephone_booths: 'oops'
            }
          end
        end

        expect { savon(:bad) }.to raise_exception(
          WashOut::Dispatcher::ProgrammerError,
          /SOAP response .*wyldness.*Array.*Hash.*stallion/
        )

        expect { savon(:bad2) }.to raise_exception(
          WashOut::Dispatcher::ProgrammerError,
          /SOAP response .*oops.*String.*telephone_booths.*Array/
        )
      end

      context 'custom exceptions' do
        let(:error_message) { 'some message' }
        let(:error_code) { 1001 }
        let(:soap_exception) { WashOut::Dispatcher::SOAPError.new(error_message, error_code) }

        before(:each) do
          # Savon::Response.raise_errors = false
        end

        it 'raises a savon soapfault' do
          mock_controller do
            soap_action 'bad', args: nil, return: nil

            def bad
              raise WashOut::Dispatcher::SOAPError.new('some message', 1001)
            end
          end

          expect { savon(:bad) }.to raise_exception{ |error|
            error_hash = error.to_hash
            expect(error_hash[:fault][:faultcode]).to eq(error_code.to_s)
            expect(error_hash[:fault][:faultstring]).to eq(error_message)
            expect(error).to be_a(Savon::SOAPFault)
          }
        end
      end
    end

    context 'deprecates' do
      it 'old syntax' do
        # save rspec context check
        raise_runtime_exception = raise_exception(RuntimeError)

        mock_controller do
          soap_action 'rumba',
                      args: :integer,
                      return: nil
          def rumba
            raise RuntimeError
          end
        end

        expect { savon(:rumba) }.to raise_runtime_exception
      end
    end

    it 'allows arbitrary action names' do
      name = 'AnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything'

      mock_controller do
        soap_action name, args: nil, return: :integer, to: :answer
        def answer
          render soap: 'forty two'
        end
      end

      expect(savon(name.underscore.to_sym)["#{name.underscore}_response".to_sym][:value]
            ).to eq 'forty two'
    end

    it 'respects :response_tag option' do
      mock_controller do
        soap_action 'specific', response_tag: 'test', return: :string
        def specific
          render soap: 'test'
        end
      end

      expect(savon(:specific)).to eq(test: { value: 'test' })
    end

    it 'handles snakecase option properly' do
      mock_controller(snakecase_input: false, camelize_wsdl: false) do
        soap_action 'rocknroll', args: { ZOMG: :string }, return: nil
        def rocknroll
          raise 'not ok' unless params['ZOMG'] == 'yam!'
          render soap: nil
        end
      end

      savon(:rocknroll, 'ZOMG' => 'yam!')
    end
  end
end
