require 'wash_out'
require 'washout_doc/soap_fault'
require 'washout_doc/soap'
#require 'washout_doc/param'
require 'washout_doc/engine'
require 'washout_doc/dispatcher'
require 'washout_doc/type'
require 'washout_doc/middleware'

module ActionDispatch::Routing
  class  Mapper

    alias_method  :original_wash_out,:wash_out

    # Adds the routes for a SOAP endpoint at +controller+.
    def wash_out(controller_name, options={})
      options.reverse_merge!(@scope) if @scope
      controller_class_name = [options[:module], controller_name].compact.join("/")

      match "#{controller_name}/doc"   => "#{controller_name}#_generate_doc", :via => :get, :format => false
      original_wash_out(controller_name, options)


    end
  end
end




Mime::Type.register "application/soap+xml", :soap
ActiveRecord::Base.send :extend, WashOut::Model if defined?(ActiveRecord)

ActionController::Renderers.add :soap do |what, options|
  _render_soap(what, options)
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
    include WashoutDoc::SOAP
    self.soap_config = options
  end
end