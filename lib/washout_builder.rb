require 'wash_out'

require 'washout_builder/soap'
require 'washout_builder/engine'
require 'washout_builder/dispatcher'
require 'washout_builder/type'


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



WashOut::Dispatcher::SOAPError.send :include, ActiveModel::MassAssignmentSecurity if defined?(WashOut::Dispatcher)
WashOut::SOAPError.send :include, ActiveModel::MassAssignmentSecurity if defined?(WashOut::SOAPError)


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
