#encoding:utf-8
require 'spec_helper'
mock_controller do
  soap_service  namespace: "/api/wsdl", description: "some description"

  soap_action 'dispatcher_method', :args => nil, :return => nil
 
  def dispatcher_method
    #nothing
  end
end

describe WashoutBuilder::Document::Generator do
  
  let(:soap_config) { OpenStruct.new(
      camelize_wsdl: false,
      namespace: "/api/wsdl",
      description: "some description"
    ) }
  
  let(:soap_actions) {
    {'dispatcher_method' => 
        {:args => nil, :return => nil, :in => [], :out => [], :builder_in => [], :builder_out => [],  :to => 'dispatcher_method'}
    }
  }
  let(:service_class) { ApiController }
  before(:each) do
    @document = WashoutBuilder::Document::Generator.new("api")
    @document.stubs(:controller_class).returns(service_class)
    
  end
    
  
  
  context "namespace" do
    specify {  @document.namespace.should eq(soap_config.namespace) }
  end
  
  context "endpoint" do
    specify {  @document.endpoint.should eq(soap_config.namespace.gsub("/wsdl", "/action")) }
  end
  
  context "service" do
    specify { @document.service.should eq(service_class.name.underscore.gsub("_controller", "").camelize) }
  end
  
  context "description" do
    specify {@document.service_description.should eq(soap_config.description )}
  end
  
  context "operations" do
    specify { @document.operations.should eq(soap_actions.map { |operation, formats| operation }) }
  end
  
  
  context "input types" do
    let(:expected) { types = []
      soap_actions.each do |operation, formats|
        (formats[:builder_in]).each do |p|
          types << p
        end
      end
      types }
    
    specify { @document.input_types.should eq(expected) }
    
  end
  
  context "output types" do
    let(:expected) { types = []
      soap_actions.each do |operation, formats|
        (formats[:builder_out]).each do |p|
          types << p
        end
      end
      types }
    
    specify { @document.output_types.should eq(expected) }
    
  end
  
  
  context "get_soap_action_names" do
    
    let(:expected) {soap_actions.map { |operation, formats| operation }.map(&:to_s).sort_by { |name| name.downcase }.uniq}
    
    specify  { @document.get_soap_action_names.should eq(expected) }
    
    
    it "returns nil on empty soap actions" do
      @document.stubs(:soap_actions).returns(nil)
      @document.get_soap_action_names.should eq(nil)
    end
    
  end
  
  
  
  context "complex types" do
    
    let(:expected){
      
    }
    
    
    it "returns nil on empty soap actions" do
      @document.stubs(:soap_actions).returns(nil)
      @document.complex_types.should eq(nil)
    end
    
    it "returns nil if no complex types detected" do
      @document.complex_types.should eq(nil)
    end
    
    
    
    
    
  end
  
  
end