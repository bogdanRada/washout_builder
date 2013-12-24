#encoding:utf-8
require 'spec_helper'

class SOAPError < WashOut::Dispatcher::SOAPError
  
end

describe WashoutBuilder::Document::VirtusModel do

  let(:subject) { SOAPError}
  
  
  
  it "gets the strcuture" do
    subject.get_virtus_model_structure.should eq({"code"=>{:primitive=>"Integer", :member_type=>nil}, "message"=>{:primitive=>"String", :member_type=>nil}, "backtrace"=>{:primitive=>"String", :member_type=>nil}})
  end
  
  it "gets the member type for arrays" do
    subject.get_virtus_member_type_primitive({:primitive=>"Array", :member_type=>"SomeInexistentClass"}).should eq("SomeInexistentClass")
  end
  
  it "gets the member type for clasified types" do
    subject.get_virtus_member_type_primitive({:primitive=>"SomeInexistentClass", :member_type=>nil}).should eq("SomeInexistentClass")
  end
    
  it "returns nil because is not a classified object" do
    subject.get_virtus_member_type_primitive({:primitive=>"integer", :member_type=>nil}).should eq(nil)
  end
  
    
  it "gets the strcuture" do
    subject.remove_fault_type_inheritable_elements(["code"]).should eq({ "message"=>{:primitive=>"String", :member_type=>nil}, "backtrace"=>{:primitive=>"String", :member_type=>nil}})
  end
  
end