# encoding:utf-8
require 'spec_helper'
mock_controller do
  soap_service namespace: '/api/wsdl', description: 'some description'

  soap_action 'dispatcher_method', args: nil, return: nil
  soap_action 'dispatcher_method2', args: nil, return: nil, raises: WashoutBuilderTestError
  soap_action 'dispatcher_method3', args: ProjectType, return: nil, raises: [WashoutBuilderTestError]
  def dispatcher_method
    # nothing
  end

  def dispatcher_method2
    # nothing
  end

  def dispatcher_method3
    # nothing
  end
end

describe WashoutBuilder::Document::Generator do
  let(:soap_config) do
    OpenStruct.new(
      camelize_wsdl: false,
      namespace: '/api/wsdl',
      description: 'some description'
    )
  end

  let(:service_class) { ApiController }
  before(:each) do
    @document = WashoutBuilder::Document::Generator.new('api')
    @document.stubs(:controller_class).returns(service_class)
  end

  context 'namespace' do
    specify { @document.namespace.should eq(soap_config.namespace) }
  end

  context 'endpoint' do
    specify { @document.endpoint.should eq(soap_config.namespace.gsub('/wsdl', '/action')) }
  end

  context 'service' do
    specify { @document.service.should eq(service_class.name.underscore.gsub('_controller', '').camelize) }
  end

  context 'description' do
    specify { @document.service_description.should eq(soap_config.description) }
  end

  context 'operations' do
    specify { @document.operations.should eq(service_class.soap_actions.map { |operation, _formats| operation }) }
  end

  context 'sorted_operations' do
    it 'returns sorted operations' do
      expected = service_class.soap_actions.sort_by { |operation, _formats| operation.downcase }.uniq
      @document.sorted_operations.should eq expected
    end
  end

  def argument_types(type)
    format_type = (type == 'input') ? 'builder_in' : 'builder_out'
    types = []
    unless service_class.soap_actions.blank?
      service_class.soap_actions.each do |_operation, formats|
        (formats[format_type.to_sym]).each do |p|
          types << p
        end
      end
    end
    types
  end

  context 'input types' do
    specify { @document.input_types.should eq(argument_types('input')) }
  end

  context 'output types' do
    specify { @document.output_types.should eq(argument_types('output')) }
  end

  context 'operation exceptions' do
    specify { @document.operation_exceptions('dispatcher_method').should eq([]) }
    specify { @document.operation_exceptions('dispatcher_method2').should eq([WashoutBuilderTestError]) }
    specify { @document.operation_exceptions('dispatcher_method3').should eq([WashoutBuilderTestError]) }
  end

  context 'all_soap_action_names' do
    let(:expected) { service_class.soap_actions.map { |operation, _formats| operation }.map(&:to_s).sort_by(&:downcase).uniq }

    specify { @document.all_soap_action_names.should eq(expected) }

    it 'returns nil on empty soap actions' do
      @document.stubs(:soap_actions).returns(nil)
      @document.all_soap_action_names.should eq(nil)
    end
  end

  context 'actions with exceptions' do
    let(:actions_with_exceptions) { service_class.soap_actions.select { |_operation, formats| !formats[:raises].blank? } }
    let(:exceptions_raised) { actions_with_exceptions.map { |_operation, formats| formats[:raises].is_a?(Array) ? formats[:raises] : [formats[:raises]] }.flatten }
    let(:filter_exceptions_raised) { exceptions_raised.select { |x| WashoutBuilder::Type.valid_fault_class?(x) } unless actions_with_exceptions.blank? }

    specify { @document.actions_with_exceptions.should eq actions_with_exceptions }
    specify { @document.exceptions_raised.should eq exceptions_raised }
    specify { @document.filter_exceptions_raised.should eq filter_exceptions_raised }

    it 'returns the fault types' do
      WashoutBuilder::Type.stubs(:all_fault_classes).returns([base_exception])
      @document.expects(:get_complex_fault_types).with([base_exception]).returns([base_exception])
      @document.expects(:sort_complex_types).with([base_exception], 'fault').returns([base_exception])
      @document.fault_types.should eq([base_exception])
    end

    it 'returns complex fault types' do
      base_exception.expects(:get_fault_class_ancestors).with([], true).returns(nil)
      @document.expects(:filter_exceptions_raised).returns(nil)
      @document.get_complex_fault_types([base_exception]).should eq([])
    end
  end

  context 'complex types' do
    let(:expected)do
    end

    it 'returns nil on empty soap actions' do
      @document.stubs(:soap_actions).returns(nil)
      @document.complex_types.should eq(nil)
    end

    it 'returns nil if no complex types detected' do
      WashOut::Param.any_instance.expects(:get_nested_complex_types).returns([])
      @document.expects(:sort_complex_types).with([], 'class').returns(nil)
      @document.complex_types.should eq(nil)
    end
  end
end
