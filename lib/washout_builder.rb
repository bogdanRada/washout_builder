require 'wash_out'
#require 'virtus'
require 'washout_builder/track_exception_attributes'
require 'washout_builder/soap'
require 'washout_builder/engine'
require 'washout_builder/document/shared_complex_type'
require 'washout_builder/document/complex_type'
require 'washout_builder/document/virtus_model'
require 'washout_builder/document/generator'
require 'washout_builder/type'
require 'washout_builder/version'



#Virtus::InstanceMethods::Constructor.class_eval do
#  alias_method  :original_initialize,:initialize
#  def initialize(attributes = nil)
#    if WashoutBuilder::Type.valid_fault_class?(self.class)
#      attributes = {:message => attributes} unless attributes.is_a?(Hash) 
#    end
#    original_initialize(attributes)
#  end
#end


WashOut::Param.send :include, WashoutBuilder::Document::ComplexType


WashoutBuilder::Type.get_fault_classes.each do |exception_class|
  exception_class.class_eval do
    extend WashoutBuilder::Document::VirtusModel
#    include Virtus.model
#    attribute :code, Integer
#    attribute :message, String
#    attribute :backtrace, String
  end
end


if defined?(WashOut::SOAP)
  WashOut::SOAP::ClassMethods.class_eval do
    alias_method :original_soap_action, :soap_action
  end
end


if defined?(WashOut::Rails::Controller)
  WashOut::Rails::Controller::ClassMethods.class_eval do
    alias_method :original_soap_action, :soap_action
  end
end

if defined?(WashOut::SoapConfig)
  WashOut::SoapConfig.class_eval do
    self.singleton_class.send(:alias_method, :original_config, :config)
    self.singleton_class.send(:alias_method, :original_keys, :keys)
      
    def self.keys
      @keys = config.keys
    end
    
    def self.config
      original_config.merge({description: nil})
    end
    
  end
  WashOut::SoapConfig.soap_accessor(:description)
end


WashOut::Param.class_eval do
   
  def self.parse_builder_def(soap_config, definition)
    raise RuntimeError, "[] should not be used in your params. Use nil if you want to mark empty set." if definition == []
    return [] if definition == nil

    definition = { :value => definition } unless definition.is_a?(Hash)

    definition.collect do |name, opt|
      if opt.is_a? WashOut::Param
        opt
      elsif opt.is_a? Array
        WashOut::Param.new(soap_config, name, opt[0], true)
      else
        WashOut::Param.new(soap_config, name, opt)
      end
    end
  end
  
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
