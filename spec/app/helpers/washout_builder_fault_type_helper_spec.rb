require 'spec_helper'

describe WashoutBuilderFaultTypeHelper, type: :helper do
  context ' create_fault_model_complex_element_type' do
    let(:pre) { [] }
    let(:attr_primitive) { 'string' }
    let(:attribute) { 'custom_attribute' }

    def check_result(array)
      attribute_primitive = array == true ? "Array of #{attr_primitive}" : "#{attr_primitive}"
      result = helper. create_fault_model_complex_element_type(pre, attr_primitive, attribute, array)
      expect(result).to eq(["<a href='##{attr_primitive}'><span class='lightBlue'> #{attribute_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"])
    end

    it 'creates an array element ' do
      check_result(true)
    end
    it 'creates an simple  element ' do
      check_result(false)
    end
  end

  context 'member_type_is_basic?' do
    it 'returns a basic type' do
      attr_details = { member_type: 'STRING' }
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(attr_details[:member_type].to_s.downcase).returns(true)
      result = helper.member_type_is_basic?(attr_details)
      expect(result).to eq(attr_details[:member_type].to_s.downcase)
    end

    it 'returns a non-basic type' do
      attr_details = { member_type: 'STRING' }
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(attr_details[:member_type].to_s.downcase).returns(false)
      result = helper.member_type_is_basic?(attr_details)
      expect(result).to eq(attr_details[:member_type])
    end
  end

  context 'primitive_type_is_basic?' do
    it 'returns true' do
      attr_details = { primitive: 'STRING' }
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(attr_details[:primitive].to_s.downcase).returns(true)
      expect(helper.primitive_type_is_basic?(attr_details)).to eq(true)
    end

    it 'returns false' do
      attr_details = { primitive: 'STRING' }
      WashoutBuilder::Type::BASIC_TYPES.expects(:include?).with(attr_details[:primitive].to_s.downcase).returns(false)
      expect(helper.primitive_type_is_basic?(attr_details)).to eq(false)
    end
  end

  context 'get_primitive_type_string' do
    %w(NILCLASS nilclass).each do |primitive|
      it 'returns string in case of nilclass' do
        attr_details = { primitive: primitive }
        expect(helper.get_primitive_type_string(attr_details)).to eq('string')
      end
    end

    %w(BLA bla).each do |primitive|
      it 'returns the primitive if not niclass' do
        attr_details = { primitive: primitive }
        expect(helper.get_primitive_type_string(attr_details)).to eq(primitive.to_s.downcase)
      end
    end
  end

  context 'get_member_type_string' do
    %w(Array array).each do |primitive|
      it 'checks the member type to be basic if primitive type array' do
        attr_details = { primitive: primitive }
        helper.expects(:member_type_is_basic?).with(attr_details).returns(true)
        expect(helper.get_member_type_string(attr_details)).to eq(true)
      end
    end

    %w(BLA Bla bla).each do |primitive|
      it 'returns the primitive type as it is if not array' do
        attr_details = { primitive: primitive }
        expect(helper.get_member_type_string(attr_details)).to eq(primitive)
      end
    end
  end

  context 'create_html_fault_model_element_type' do
    let(:pre) { [] }
    let(:attribute) { 'some_attribute' }

    before(:each) do
      helper.stubs(:primitive_type_is_basic?).returns(false)
    end

    def expect_type_string_elem_type(attr_details)
      type_string = 'string'
      helper.expects(:get_primitive_type_string).with(attr_details).returns(type_string)
      result = helper.create_html_fault_model_element_type(pre, attribute, attr_details)
      expect(result).to eq(["<span class='blue'>#{type_string}</span>&nbsp;<span class='bold'>#{attribute}</span>"])
    end

    it 'returns the string element if primitive type is nilclass' do
      attr_details = { primitive: 'nilclass' }
      expect_type_string_elem_type(attr_details)
    end

    %w(NILCLASS Nilclass BLA).each do |primitive|
      it 'returns the string type is primitive is basic but not nilclass' do
        attr_details = { primitive: primitive }
        helper.expects(:primitive_type_is_basic?).with(attr_details).returns(true)
        expect_type_string_elem_type(attr_details)
      end
    end

    %w(NILCLASS Nilclass BLA).each do |primitive|
      it 'returns the complex type if not basic and not nilclass' do
        attr_details = { primitive: primitive }
        member_type = 'SomeMemberType'
        expected = 'Some expected string'
        helper.expects(:primitive_type_is_basic?).with(attr_details).returns(false)
        helper.expects(:get_member_type_string).with(attr_details).returns(member_type)
        helper.expects(:create_fault_model_complex_element_type).with(pre, member_type, attribute, true).returns(expected)
        result = helper.create_html_fault_model_element_type(pre, attribute, attr_details)
        expect(result).to eq(expected)
      end
    end
  end
end
