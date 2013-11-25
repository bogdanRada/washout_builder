require 'nori'

module WashoutBuilder
  # The WashoutBuilder::Dispatcher module should be included in a controller acting
  # as a SOAP endpoint. It includes actions for generating WSDL and handling
  # SOAP requests.
  module Dispatcher
    extend WashOut::Dispatcher

    def _generate_doc
      @map       = self.class.soap_actions
      @namespace = soap_config.namespace
      @name      = controller_path.gsub('/', '_')
      @service = self.class.name.underscore.gsub("_controller", "").camelize
      @endpoint  = @namespace.gsub("/wsdl", "/action")

      render :template => "wash_with_html/doc", :layout => false,
        :content_type => 'text/html'
    end

    def self.included(controller)
      controller.send :rescue_from, WashOut::Dispatcher::SOAPError, :with => :_render_soap_exception
      controller.send :helper, :wash_out, :washout_builder
      controller.send :before_filter, :_parse_soap_parameters, :except => [
        :_generate_wsdl, :_generate_doc, :_invalid_action ]
      controller.send :before_filter, :_authenticate_wsse,     :except => [
        :_generate_wsdl,:_generate_doc,:_invalid_action ]
      controller.send :before_filter, :_map_soap_parameters,   :except => [
        :_generate_wsdl, :_generate_doc,:_invalid_action ]
      controller.send :skip_before_filter, :verify_authenticity_token
      controller.send :around_filter, :_catch_soap_faults
    end

    def _catch_soap_faults
      yield
    rescue => exception
      if exception.class <= WashOut::Dispatcher::SOAPError
        _render_soap_fault_exception(exception)
      else
        raise exception
      end
    end
  end
end