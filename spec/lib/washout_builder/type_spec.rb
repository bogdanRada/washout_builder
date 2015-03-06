# encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Type do
  let(:exception) { WashoutBuilderTestError }
  let(:fault_classes) { [exception] }

  it 'defines a list of types' do
    WashoutBuilder::Type::BASIC_TYPES.should eq(%w(string integer double boolean date datetime float time int))
  end

  it 'gets the fault classes defined' do
    WashoutBuilder::Type.all_fault_classes.should eq([base_exception])
  end

  context 'exception' do
    before(:each) do
      WashoutBuilder::Type.stubs(:all_fault_classes).returns([base_exception])
    end

    it 'checks if exception has ancestor' do
      WashoutBuilder::Type.ancestor_fault?(exception).should eq(true)
    end

    it 'checks if exception valid' do
      WashoutBuilder::Type.valid_fault_class?(exception).should eq(true)
    end
  end
end
