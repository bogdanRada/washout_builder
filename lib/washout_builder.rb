require 'wash_out'
require 'virtus'
require 'washout_builder/soap'
require 'washout_builder/engine'
require 'washout_builder/document/generator'
require 'washout_builder/document/complex_type'
require 'washout_builder/dispatcher'
require 'washout_builder/type'
require 'washout_builder/version'


module ActionDispatch::Routing
  class  Mapper

    alias_method  :original_wash_out,:wash_out

    # Adds the routes for a SOAP endpoint at +controller+.
    def wash_out(controller_name, options={})
      options.reverse_merge!(@scope) if @scope

      match "#{controller_name}/doc"   => "#{controller_name}#_generate_doc", :via => :get, :format => false
      original_wash_out(controller_name, options)


    end
  end
end


WashOut::Param.send :include, WashoutBuilder::Document::ComplexType

WashOut::SOAPError.class_eval do
  include Virtus.model
  include  WashoutBuilder::Document::FaultType
  attribute :code, Integer
  attribute :message, String
  attribute :backtrace, String
end


ActionController::Base.class_eval do

  # Define a SOAP service. The function has no required +options+:
  # but allow any of :parser, :namespace, :wsdl_style, :snakecase_input,
  # :camelize_wsdl, :wsse_username, :wsse_password and :catch_xml_errors.
  #
  # Any of the the params provided allows for overriding the defaults
  # (like supporting multiple namespaces instead of application wide such)
  #
  def self.soap_service(options={})
    include WashoutBuilder::SOAP
    self.soap_config = options
  end
end
