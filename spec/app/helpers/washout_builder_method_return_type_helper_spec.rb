require 'spec_helper'

describe WashoutBuilderMethodReturnTypeHelper, type: :helper do
  let!(:xml) { Builder::XmlMarkup.new }
  let(:pre) { [] }

  context 'create_html_public_method_return_type' do
    let(:complex_class) { 'SomeComplexClass' }
    let (:builder_elem) { mock }
    let(:output) { [builder_elem] }
    let(:type) { 'string' }

    before(:each) do
      builder_elem.stubs(:find_complex_class_name).returns(complex_class)
      builder_elem.stubs(:type).returns(type)
    end

    it 'returns void if output nil' do
      result = helper.create_html_public_method_return_type(xml, pre, nil)
      result.should eq(['void'])
    end

    it 'returns basic type' do
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(true)
      result = helper.create_html_public_method_return_type(xml, pre, output)
      result.should eq("<span class=\"blue\">#{type}</span>")
    end

    it 'returns simeple complex typel' do
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(false)
      builder_elem.expects(:multiplied).returns(false)
      result = helper.create_html_public_method_return_type(xml, pre, output)
      result.should eq(["<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>"])
    end

    it 'returns array of complex typel' do
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(false)
      builder_elem.expects(:multiplied).returns(true)
      result = helper.create_html_public_method_return_type(xml, pre, output)
      result.should eq(["<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>"])
    end

    it 'returns nil if complex class is nil' do
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(false)
      builder_elem.expects(:find_complex_class_name).returns(nil)
      result = helper.create_html_public_method_return_type(xml, pre, output)
      result.should eq(nil)
    end
  end
end
