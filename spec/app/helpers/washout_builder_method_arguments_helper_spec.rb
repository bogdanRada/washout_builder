require 'spec_helper'

describe WashoutBuilderMethodArgumentsHelper, type: :helper do
  let!(:xml) { Builder::XmlMarkup.new }

  context 'create_method_argument_element' do
    let(:spacer) { '&nbsp;&nbsp;&nbsp;&nbsp;' }
    let(:pre) { [] }
    let(:param) { mock }
    let(:complex_class) { 'SomeComplexClass' }
    let(:param_type) { 'string' }
    let(:param_name) { 'some_param_name' }

    before(:each) do
      param.stubs(:find_complex_class_name).returns(complex_class)
      param.stubs(:type).returns(param_type)
      param.stubs(:name).returns(param_name)
    end

    def expect_method_arg_basic_type(mlen)
      use_spacer = mlen > 1 ? true : false
      result = helper.create_method_argument_element(pre, param, mlen)
      result.should eq(["#{use_spacer ? spacer : ''}<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"])
    end

    [0, 1, 2, 3, 4].each do |mlen|
      it 'returns a basic type' do
        WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(param.type).returns(true)
        expect_method_arg_basic_type(mlen)
      end
    end

    [0, 1, 2, 3, 4].each do |mlen|
      it 'returns array of complex type' do
        WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(param.type).returns(false)
        param.expects(:multiplied).returns(true)
        use_spacer = mlen > 1 ? true : false
        result = helper.create_method_argument_element(pre, param, mlen)
        result.should eq(["#{use_spacer ? spacer : ''}<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"])
      end
    end

    [0, 1, 2, 3, 4].each do |mlen|
      it 'returns  simple complex type' do
        WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(param.type).returns(false)
        param.expects(:multiplied).returns(false)
        use_spacer = mlen > 1 ? true : false
        result = helper.create_method_argument_element(pre, param, mlen)
        result.should eq(["#{use_spacer ? spacer : ''}<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"])
      end
    end
  end

  context 'create_argument_element_spacer' do
    it 'returns only the ) in bold ' do
      helper.create_argument_element_spacer(xml, 0, 1)
      xml.target!.should eq("<span class=\"bold\">)</span>")
    end

    it 'returns only the span with comma' do
      helper.create_argument_element_spacer(xml, -2, 1)
      xml.target!.should eq('<span>, </span>')
    end

    it 'returns only the span with comma and a break ' do
      helper.create_argument_element_spacer(xml, 1, 3)
      xml.target!.should eq('<span>, </span><br/>')
    end

    it 'returns a break and a ) sign  ' do
      helper.create_argument_element_spacer(xml, 2, 3)
      xml.target!.should eq("<br/><span class=\"bold\">)</span>")
    end

    [3, 4, 4, 5, 6].each do |j_value|
      it 'returns only the span with comma ' do
        helper.create_argument_element_spacer(xml, j_value, 3)
        xml.target!.should eq('<br/>')
      end
    end
  end

  context 'create_html_public_method_arguments' do
    let(:pre) { [] }
    let(:element) { mock }
    let(:second_element) { mock }

    it 'returns only the span with comma ' do
      input = [element, second_element]

      helper.stubs(:create_method_argument_element).returns('bla')
      helper.stubs(:create_argument_element_spacer).returns('blabla')
      helper. create_html_public_method_arguments(xml, pre, input)
      xml.target!.should eq('<br/>')
    end
  end
end
