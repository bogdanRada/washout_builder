require 'wash_out'
Gem.find_files("washout_builder/**/*.rb").each { |path| require path }

WashOut::Param.send :include, WashoutBuilder::Document::ComplexType


WashoutBuilder::Type.get_fault_classes.each do |exception_class|
  exception_class.class_eval do
    extend WashoutBuilder::Document::ExceptionModel
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
    
    # the following lines was removed because when generating the documentation
    #  the "source_class" attrtibute of the object was not the name of the class of the complex tyoe
    # but instead was the name given in the hash
    # Example :
    #  class ProjectType < WashOut::Type
    #  map :project => {
    # :name                                    => :string,
    #  :description                           => :string,
    #  :users                                    => [{:mail => :string }],
    #  }
    #end
    # 
    # The name of the complex type should be ProjectType and not "project"
    
    
    #     if definition.is_a?(Class) && definition.ancestors.include?(WashOut::Type)
    #        definition = definition.wash_out_param_map
    #    end
    
    definition = { :value => definition } unless definition.is_a?(Hash) # for arrays and symbols
    
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
