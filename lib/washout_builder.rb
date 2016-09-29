require 'wash_out'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'active_support/concern'
require 'active_support/core_ext/string/output_safety'
require 'active_support/ordered_options'
require 'active_support/core_ext/string/starts_ends_with'

Gem.find_files('washout_builder/**/*.rb').each { |path| require path }

ActionDispatch::Routing::Mapper.class_eval do
  alias_method :original_wash_out, :wash_out
  # Adds the routes for a SOAP endpoint at +controller+.
  def wash_out(controller_name, options={})
    env_checker = WashoutBuilder::EnvChecker.new(Rails.application)
    if env_checker.available_for_env?(Rails.env)
      options = options.symbolize_keys if options.is_a?(Hash)
      if @scope
        scope_frame = @scope.respond_to?(:frame) ? @scope.frame : @scope
        # needed for backward compatibility with old version when this module name was camelized
        options[:module] = options[:module].to_s.underscore if options[:module].present?
        options.each { |key, value|  scope_frame[key] = value }
        controller_class_name = [scope_frame[:module], controller_name].compact.join("/").underscore
      else
        controller_class_name = controller_name.to_s.underscore
      end
      match "#{controller_name}/soap_doc" => WashoutBuilder::Router.new(controller_class_name), via: :get,
      format: false,
      as: "#{controller_class_name}_soap_doc"
    end
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
