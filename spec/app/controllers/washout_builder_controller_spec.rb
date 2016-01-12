require 'spec_helper'
mock_controller do
  soap_action 'dispatcher_method', args: nil, return: nil

  def dispatcher_method
    # nothing
  end
end
describe WashoutBuilder::WashoutBuilderController, type: :controller do
  routes { WashoutBuilder::Engine.routes }

  let(:soap_config) do
    OpenStruct.new(
      camelize_wsdl: false,
      namespace: '/api/wsdl'
    )
  end

  let(:washout_builder) { stub(root_url: "#{request.protocol}#{request.host_with_port}/") }
  let(:route) { stub(defaults: { controller: 'api' }) }
  let(:params) { { name: 'some_name' } }

  before(:each) do
    ApiController.stubs(:soap_config).returns(soap_config)
    controller.stubs(:washout_builder).returns(washout_builder)
  end

  it 'gets the services' do
    get :all
    expect(assigns(:services)).to eq([{ 'service_name' => 'Api', 'namespace' => '/api/wsdl', 'endpoint' => '/api/action', 'documentation_url' => 'http://test.host/Api' }])
  end

  it 'renders the template' do
    get :all
    expect(response).to render_template('wash_with_html/all_services')
  end

  it 'checks it controller is a service' do
    controller.send(:find_all_routes)
    expect(controller.send(:controller_is_a_service?, 'api')).not_to eq nil
  end

  it 'render a service documentation' do
    controller.expects(:controller_is_a_service?).with(params[:name]).returns(route)
    WashoutBuilder::Document::Generator.expects(:new).with(route.defaults[:controller])
    get :all, params
    expect(response).to render_template 'wash_with_html/doc'
  end
end
