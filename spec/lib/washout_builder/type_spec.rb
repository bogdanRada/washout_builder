# encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Type do
  let(:exception) { WashoutBuilderTestError }
  let(:fault_classes) { [exception] }

  it 'defines a list of types' do
     expect(WashoutBuilder::Type::BASIC_TYPES).to eq(%w(string integer double boolean date datetime float time int))
  end

  it 'gets the fault classes defined' do
     expect(WashoutBuilder::Type.all_fault_classes).to eq([base_exception])
  end

  context 'exception' do
    before(:each) do
      WashoutBuilder::Type.stubs(:all_fault_classes).returns([base_exception])
    end

    it 'checks if exception has ancestor' do
       expect(WashoutBuilder::Type.ancestor_fault?(exception)).to eq(true)
    end

    it 'checks if exception valid' do
       expect(WashoutBuilder::Type.valid_fault_class?(exception)).to eq(true)
    end
  end
end
