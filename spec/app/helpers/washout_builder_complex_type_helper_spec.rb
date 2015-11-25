require 'spec_helper'

describe WashoutBuilderComplexTypeHelper, type: :helper do
  context '#create_element_type_html' do
    let(:pre) { [] }
    let(:element_name) { 'custom_name' }
    let(:element) { mock }

    before(:each) do
      element.stubs(:type).returns('text')
      element.stubs(:type=).with('string')
      element.stubs(:name).returns(element_name)
    end

    def expect_included_type_result(pre, element)
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(element.type).returns(true)
      result = helper.create_element_type_html(pre, element, nil)
      expect(result).to eq(["<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"])
    end

    def expect_excluded_type_result(pre, element)
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(element.type).returns(false)
      helper.expects(:create_complex_element_type_html).with(pre, element)
      helper.create_element_type_html(pre, element, nil)
    end

    it 'returns the element of type text' do
      element.expects(:type=).with('string')
      expect_included_type_result(pre, element)
    end

    it 'returns the element of type text' do
      expect_excluded_type_result(pre, element)
    end

    it 'returns the element of type integer' do
      element.stubs(:type).returns('int')
      element.expects(:type=).with('integer')
      expect_included_type_result(pre, element)
    end

    it 'returns the element of type integer' do
      element.stubs(:type).returns('int')
      element.expects(:type=).with('integer')
      expect_excluded_type_result(pre, element)
    end
  end

  context 'create_complex_element_type_html' do
    let(:pre) { [] }
    let(:element_name) { 'custom_name' }
    let(:complex_class) { 'SomeClass' }
    let(:element) { mock }

    before(:each) do
      element.stubs(:find_complex_class_name).returns(complex_class)
      element.stubs(:multiplied).returns(false)
      element.stubs(:name).returns(element_name)
    end

    it 'returna simple type element description' do
      result = helper.create_complex_element_type_html(pre, element)
      expect(result).to eq(["<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"])
    end

    it 'returns an array type element description' do
      element.stubs(:multiplied).returns(true)
      result = helper.create_complex_element_type_html(pre, element)
      expect(result).to eq(["<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"])
    end

    it 'returns empty if no complex class' do
      element.stubs(:find_complex_class_name).returns(nil)
      result = helper.create_complex_element_type_html(pre, element)
      expect(result).to eq(nil)
    end
  end
end
