require 'spec_helper'

describe WashoutBuilderMethodListHelper, type: :helper do
  let!(:xml) { Builder::XmlMarkup.new }

  context 'create_return_complex_type_list_html' do
    let(:complex_class) { 'SomeComplexClass' }
    let (:builder_elem) { mock }
    let(:builder_out) { [builder_elem] }

    it 'returns simple type ' do
      builder_elem.expects(:multiplied).returns(false)
      result = helper.create_return_complex_type_list_html(xml, complex_class, builder_out)
      result.should eq("<span class=\"pre\"><a href=\"#SomeComplexClass\"><span class=\"lightBlue\">SomeComplexClass</span></a></span>")
    end

    it 'returns array type ' do
      builder_elem.expects(:multiplied).returns(true)
      result = helper.create_return_complex_type_list_html(xml, complex_class, builder_out)
      result.should eq("<span class=\"pre\"><a href=\"#SomeComplexClass\"><span class=\"lightBlue\">Array of SomeComplexClass</span></a></span>")
    end
  end

  context 'create_return_type_list_html' do
    let(:complex_class) { 'SomeComplexClass' }
    let (:builder_elem) { mock }
    let(:output) { [builder_elem] }
    let(:type) { 'string' }

    before(:each) do
      builder_elem.stubs(:find_complex_class_name).returns(complex_class)
      builder_elem.stubs(:type).returns(type)
    end

    it 'returns void for nil' do
      helper.create_return_type_list_html(xml, nil)
      xml.target!.should eq("<span class=\"pre\">void</span>")
    end

    it 'returns basic type' do
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(true)
      helper.create_return_type_list_html(xml, output)
      xml.target!.should eq("<span class=\"pre\"><span class=\"blue\">string</span></span>")
    end
    it 'returns complex type' do
      expected = 'some expected string'
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(false)
      helper.expects(:create_return_complex_type_html).with(instance_of(Builder::XmlMarkup), complex_class, output).returns(expected)
      result = helper.create_return_type_list_html(xml, output)
      result.should eq(expected)
    end

    it 'returns nil if complex class is nil' do
      builder_elem.stubs(:find_complex_class_name).returns(nil)
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(builder_elem.type).returns(false)
      result = helper.create_return_type_list_html(xml, output)
      result.should eq(nil)
    end
  end
end
