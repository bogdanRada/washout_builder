class WashoutBuilderController < ActionController::Base
  protect_from_forgery

  def all
    # get a list of unique controller names
    controllers = Rails.application.routes.routes.map do |route|
      if route.defaults[:action] == "_generate_doc"
        {:class => "#{route.defaults[:controller]}_controller".camelize.constantize, :name => route.defaults[:controller] }
      end
    end.uniq.compact

    @services = []
    unless controllers.blank?
      controllers.map do |hash|
        namespace  = hash[:class].soap_config.namespace
        @services << {
          :service_name =>  hash[:class].to_s.underscore.gsub("_controller", "").camelize ,
          :namespace => namespace,
          :endpoint => namespace.gsub("/wsdl", "/action"),
          :documentation_url => "#{request.protocol}#{request.host_with_port}/#{hash[:name]}/doc",
        }
      end
    end


    render :template => "wash_with_html/all_services", :layout => false,
      :content_type => 'text/html'

  end




end
