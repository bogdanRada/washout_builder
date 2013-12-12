
module WashoutBuilder
  # The WashoutBuilder::Dispatcher module should be included in a controller acting
  # as a SOAP endpoint. It includes actions for generating WSDL and handling
  # SOAP requests.
  module Dispatcher
    
    def _generate_doc
      @map = self.class.soap_actions
      @document = WashoutBuilder::Document::Generator.new(
        :config => soap_config, 
        :service_class => self.class,  
        :soap_actions => self.class.soap_actions
      )
      
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