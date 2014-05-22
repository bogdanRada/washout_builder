class WashoutBuilder::WashoutBuilderController < ActionController::Base
  protect_from_forgery

  def all
    if params[:name].present? && controller_is_a_service?(params[:name])
      redirect_to service_documentation_url(params[:name])
    else
      all_services
    end
  end
  
  
  private
  
  def all_services
    @map_controllers = map_controllers
    @services = @map_controllers.blank? ? [] : @map_controllers.map do |controller_name|
      {
        'service_name' =>   controller_name.camelize  ,
        'namespace' => service_namespace(controller_name),
        'endpoint' => service_endpoint(controller_name),
        'documentation_url' => service_documentation_url(controller_name),
      }
    end
      
    render :template => "wash_with_html/all_services", :layout => false,
      :content_type => 'text/html'
  end
  
  def all_controllers
    Rails.application.routes.routes
  end
  
  def map_controllers
    all_controllers.map do |route|
      route.defaults[:controller]   if route.defaults[:action] == "_generate_doc"
    end.uniq.compact
  end
  
  def  controller_is_a_service?(controller)
    route = all_controllers.detect do |route|
      route.defaults[:controller] == controller && route.defaults[:action] == "_generate_doc"
    end
    route.present? ? true : false
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
