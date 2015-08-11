# encoding:utf-8
require 'spec_helper'

class InheritedExceptionModel
  include WashoutBuilder::Document::ExceptionModel
end

describe WashoutBuilder::Document::ExceptionModel do
  let(:subject) { WashoutBuilderTestError }

  let(:structure) { { 'message' => { primitive: 'string', member_type: nil }, 'backtrace' => { primitive: 'string', member_type: nil } } }
  let(:base_structure) { { 'code' => { primitive: 'integer', member_type: nil }, 'message' => { primitive: 'string', member_type: nil }, 'backtrace' => { primitive: 'string', member_type: nil } } }
  let(:ancestors) { [base_exception] }

  [
    WashoutBuilder::Document::SharedComplexType
  ].each do |extension|
    specify { expect(described_class.included_modules).to include(extension) }
  end

  specify { expect(InheritedExceptionModel.included_modules).to include(WashoutBuilder::Document::SharedComplexType) }

  def fault_ancestor_hash(subject, structure, ancestors)
    { fault: subject, structure: structure, ancestors: ancestors }
  end

  it 'gets the strcuture' do
    expect(subject.find_fault_model_structure).to eq(structure)
  end

  it 'gets the strcuture' do
    expect(base_exception.find_fault_model_structure).to eq(base_structure)
  end
  it 'gets the strcuture' do
    expect(subject.find_fault_attributes).to eq(%w(message backtrace))
  end
  it 'gets the strcuture' do
    expect(base_exception.find_fault_attributes).to eq(%w(code message backtrace))
  end

  specify { expect(subject.check_valid_fault_method?('code')).to eq(true) }
  specify { expect(subject.get_fault_type_method('code')).to eq('integer') }
  specify { expect(subject.get_fault_type_method('message')).to eq('string') }
  specify {  expect(subject.get_fault_type_method('backtrace')).to eq('string') }

  it 'gets the strcuture' do
    expect(subject.remove_fault_type_inheritable_elements(['code'])).to eq('message' => { primitive: 'string', member_type: nil }, 'backtrace' => { primitive: 'string', member_type: nil })
  end

  it 'fault_ancestor_hash' do
    expect(subject.fault_ancestor_hash(structure, ancestors)).to eq(fault_ancestor_hash(subject, structure, ancestors))
  end

  it 'gets the fault_ancestors' do
    subject.expects(:get_complex_type_ancestors).with(subject, ['ActiveRecord::Base', 'Object', 'BasicObject', 'Exception']).returns(ancestors)
    expect(subject.fault_ancestors).to eq ancestors
  end

  it 'gets the attribute type' do
    expect(subject.get_fault_type_method('some_name')).to eq 'string'
  end

  it 'gets the fault_without_inheritable_elements' do
    ancestors[0].expects(:find_fault_model_structure).returns(structure)
    subject.expects(:remove_fault_type_inheritable_elements).with(structure.keys)
    subject.fault_without_inheritable_elements(ancestors)
  end

  it 'gets the ancestors' do
    subject.expects(:fault_ancestors).returns(nil)
    subject.expects(:find_fault_model_structure).returns(structure)
    subject.expects(:fault_ancestor_hash).with(structure, []).returns(fault_ancestor_hash(subject, structure, ancestors))
    expect(subject.get_fault_class_ancestors([])).to eq(nil)
  end

  it 'gets the ancestors' do
    expected_defined = fault_ancestor_hash(subject, structure, ancestors)
    subject.expects(:fault_ancestors).returns(ancestors)
    subject.expects(:fault_without_inheritable_elements).with(ancestors).returns(structure)
    subject.expects(:fault_ancestor_hash).returns(expected_defined)
    subject.get_fault_class_ancestors([])
  end
end
