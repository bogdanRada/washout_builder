class WashoutBuilder::WashoutBuilderController < ActionController::Base
  protect_from_forgery

  def all
   
    @map_controllers = map_controllers
    @services = []
    unless @map_controllers.blank?
      @services = @map_controllers.map do |controller_name|
        {
          'service_name' =>   controller_name.camelize  ,
          'namespace' => service_namespace(controller_name),
          'endpoint' => service_endpoint(controller_name),
          'documentation_url' => service_documentation_url(controller_name),
        }
      end
    end

    render :template => "wash_with_html/all_services", :layout => false,
      :content_type => 'text/html'

  end

  private
  
  def all_controllers
    Rails.application.routes.routes
  end
  
  def map_controllers
    all_controllers.map do |route|
      route.defaults[:controller]   if route.defaults[:action] == "_generate_doc"
    end.uniq.compact
  end

  def controller_class(controller)
    "#{controller}_controller".camelize.constantize
  end
  
  def service_namespace(controller_name)
    controller_class(controller_name).soap_config.namespace
  end
  
  def service_endpoint(controller_name)
    service_namespace(controller_name).gsub("/wsdl", "/action")
  end
  
  def service_documentation_url(controller_name)
    "#{request.protocol}#{request.host_with_port}/#{controller_name}/doc"
  end

end
