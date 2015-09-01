require 'wash_out'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'active_support/concern'
Gem.find_files('washout_builder/**/*.rb').each { |path| require path }

WashoutBuilder::Type.all_fault_classes.each do |exception_class|
  exception_class.class_eval do
    extend WashoutBuilder::Document::ExceptionModel
  end
end

WashoutBuilder::Type.all_controller_classes.each do |controller|
  controller.class_eval do
    alias_method :original_soap_action, :soap_action
    include WashoutBuilder::SOAP
  end
end

WashoutBuilder::Type.all_param_classes.each do |controller|
  controller.class_eval do
    extend WashoutBuilder::Param
    include WashoutBuilder::Document::ComplexType
  end
end

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
