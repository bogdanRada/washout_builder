#encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Type do

  let(:exception) { WashOut::Dispatcher::SOAPError}
  let(:fault_classes) {  [exception]  }
  
  it "defines a list of types" do
    WashoutBuilder::Type::BASIC_TYPES.should eq([ 
        "string",
        "integer",
        "double",
        "boolean",
        "date",
        "datetime",
        "float",
        "time",
        "int"])
  end
  
  it "gets the fault classes defined" do
    WashoutBuilder::Type.get_fault_classes.should eq fault_classes
  end
  
  context "exception" do
    before(:each) do
      WashoutBuilder::Type.stubs(:get_fault_classes).returns(fault_classes)
    end
    
    it "checks if exception has ancestor" do
      WashoutBuilder::Type.has_ancestor_fault?(exception).should eq(true)
    end
    
    it "checks if exception valid" do
      WashoutBuilder::Type.stubs(:has_ancestor_fault?).returns(true)
      WashoutBuilder::Type.valid_fault_class?(exception).should eq(true)
    end
  end
  
 
end