#encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Dispatcher do

  class Dispatcher < ApplicationController
    soap_service

    def params
      @_params
    end
  end




  describe "#_load_params" do
    let(:dispatcher) { Dispatcher.new }
    let(:soap_config) { 
      OpenStruct.new(
        WashOut::Rails::Engine.config.wash_out.merge( { camelize_wsdl: false })
      )
    }
    it "should load params for an array" do
      spec = WashOut::Param.parse_def(soap_config, {:my_array => [:integer] } )
      xml_data = {:my_array => [1, 2, 3]}
      dispatcher._load_params(spec, xml_data).should == {"my_array" => [1, 2, 3]}
    end

    it "should load params for an empty array" do
      spec = WashOut::Param.parse_def(soap_config, {:my_array => [:integer] } )
      xml_data = {}
      dispatcher._load_params(spec, xml_data).should == {}
    end

    it "should load params for a nested array" do
      spec = WashOut::Param.parse_def(soap_config, {:nested => {:my_array => [:integer]}} )
      xml_data = {:nested => {:my_array => [1, 2, 3]}}
      dispatcher._load_params(spec, xml_data).should == {"nested" => {"my_array" => [1, 2, 3]}}
    end

    it "should load params for an empty nested array" do
      spec = WashOut::Param.parse_def(soap_config, {:nested => {:empty => [:integer] }} )
      xml_data = {:nested => nil}
      dispatcher._load_params(spec, xml_data).should == {"nested" => {}}
    end

  end

end
