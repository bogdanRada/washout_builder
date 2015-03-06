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
    specify { described_class.included_modules.should include(extension) }
  end

  specify { InheritedExceptionModel.included_modules.should include(WashoutBuilder::Document::SharedComplexType) }

  def fault_ancestor_hash(subject, structure, ancestors)
    { fault: subject, structure: structure, ancestors: ancestors }
  end

  it 'gets the strcuture' do
    subject.find_fault_model_structure.should eq(structure)
  end

  it 'gets the strcuture' do
    base_exception.find_fault_model_structure.should eq(base_structure)
  end
  it 'gets the strcuture' do
    subject.find_fault_attributes.should eq(%w(message backtrace))
  end
  it 'gets the strcuture' do
    base_exception.find_fault_attributes.should eq(%w(code message backtrace))
  end

  specify { subject.check_valid_fault_method?('code').should eq(true) }
  specify { subject.get_fault_type_method('code').should eq('integer') }
  specify { subject.get_fault_type_method('message').should eq('string') }
  specify { subject.get_fault_type_method('backtrace').should eq('string') }

  it 'gets the strcuture' do
    subject.remove_fault_type_inheritable_elements(['code']).should eq('message' => { primitive: 'string', member_type: nil }, 'backtrace' => { primitive: 'string', member_type: nil })
  end

  it 'fault_ancestor_hash' do
    subject.fault_ancestor_hash(structure, ancestors).should eq(fault_ancestor_hash(subject, structure, ancestors))
  end

  it 'gets the fault_ancestors' do
    subject.expects(:get_complex_type_ancestors).with(subject, ['ActiveRecord::Base', 'Object', 'BasicObject', 'Exception']).returns(ancestors)
    subject.fault_ancestors.should eq ancestors
  end

  it 'gets the attribute type' do
    subject.get_fault_type_method('some_name').should eq 'string'
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
    subject.get_fault_class_ancestors([]).should eq(nil)
  end

  it 'gets the ancestors' do
    expected_defined = fault_ancestor_hash(subject, structure, ancestors)
    subject.expects(:fault_ancestors).returns(ancestors)
    subject.expects(:fault_without_inheritable_elements).with(ancestors).returns(structure)
    subject.expects(:fault_ancestor_hash).returns(expected_defined)
    subject.get_fault_class_ancestors([])
  end
end
