require 'wash_out'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'active_support/concern'
require 'active_support/core_ext/string/output_safety.rb'

Gem.find_files('washout_builder/**/*.rb').each { |path| require path }


ActionDispatch::Routing::Mapper.class_eval do
  alias_method :original_wash_out, :wash_out
    # Adds the routes for a SOAP endpoint at +controller+.
    def wash_out(controller_name, options={})
      if @scope
        scope_frame = @scope.respond_to?(:frame) ? @scope.frame : @scope
        options.each_with_index { |key, value|  scope_frame[key] = value }
      end

      controller_class_name = [options[:module], controller_name].compact.join("/").underscore

      match "#{controller_name}/doc"   => "#{controller_name}#_generate_doc", :via => :get, :format => false,
        :as => "#{controller_class_name}_doc"
        original_wash_out(controller_name, options)
    end
end

# finds all the exception class and extends them by including the ExceptionModel module in order to be
# able to generate documentation for exceptions
WashoutBuilder::Type.all_fault_classes.each do |exception_class|
  exception_class.class_eval do
    extend WashoutBuilder::Document::ExceptionModel
  end
end

WashoutBuilder::Type.all_soap_handlers.each do |soap_handler|
  soap_handler.class_eval do
    def self.included(base)
      base.send :include, WashoutBuilder::SOAP::DocHandler
    end
  end
end

# finds all the classes that have defined the "soap_action" method and overrides it so that
# it parses the definition properly for generating documentation
WashoutBuilder::Type.all_controller_classes.each do |controller|
  controller.class_eval do
    alias_method :original_soap_action, :soap_action
    include WashoutBuilder::SOAP
  end
end

# find the class that is used for parsing definition of soap actions and add method for parsing definition
# and also includes the ComplexType module that is used for generating documentation
base_param_class = WashoutBuilder::Type.base_param_class
if base_param_class.present?
  base_param_class.class_eval do
    extend WashoutBuilder::Param
    include WashoutBuilder::Document::ComplexType
  end
end

# finds all the soap config classes that have the methods "config" and "keys" and overrides them in order to add the "description"key to the allowed keys
# this will allow webservices to specify a description besides the namespace and endpoint
WashoutBuilder::Type.all_soap_config_classes.each do |controller|
  controller.class_eval do
    singleton_class.send(:alias_method, :original_config, :config)
    singleton_class.send(:alias_method, :original_keys, :keys)

    def self.keys
      @keys = config.keys
    end

    def self.config
      original_config.merge(description: nil)
    end
  end
  controller.soap_accessor(:description)
end
