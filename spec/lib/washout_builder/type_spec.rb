#encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Type do

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
    subject.expects(:defined?).with(WashOut::SOAPError).returns(false)
    subject.expects(:defined?).with(WashOut::Dispatcher::SOAPError).returns(true)
     subject.expects(:defined?).with(SOAPError).returns(false)
     WashoutBuilder::Type.get_fault_classes.should eq [WashOut::Dispatcher::SOAPError]
  end
  
  
  
 
end