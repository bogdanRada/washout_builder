
module WashoutBuilder
  # The WashoutBuilder::Dispatcher module should be included in a controller acting
  # as a SOAP endpoint. It includes actions for generating WSDL and handling
  # SOAP requests.
  module Dispatcher
    
    def _generate_doc
      @map       = self.class.soap_actions
      @namespace = soap_config.namespace
      @name      = controller_path.gsub('/', '_')
      @service = self.class.name.underscore.gsub("_controller", "").camelize
      @endpoint  = @namespace.gsub("/wsdl", "/action")
      @soap_config = soap_config

      render :template => "wash_with_html/doc", :layout => false,
        :content_type => 'text/html'
    end
     
    def self.included(controller)
      controller.send :helper,:washout_builder
      controller.send :before_filter, :_authenticate_wsse, :except => [
        :_generate_wsdl, :_generate_doc,:_invalid_action ]
      controller.send :before_filter, :_map_soap_parameters, :except => [
        :_generate_wsdl,:_generate_doc, :_invalid_action ]
    end
    
  end
end