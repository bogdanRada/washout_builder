class WashoutDocController < ActionController::Base
  protect_from_forgery

  def all
    # get a list of unique controller names
    controllers = Rails.application.routes.routes.map do |route|
      if route.defaults[:action] == "_generate_doc"
       {:class => "#{route.defaults[:controller]}_controller".camelize.constantize, :name => route.defaults[:controller] }
      end
    end.uniq.compact

    @services = []

    controllers.map do |hash|
      namespace  = hash[:class].soap_config.namespace
      @services << {
        :service_name =>  hash[:class].to_s.demodulize ,
        :namespace => namespace,
        :endpoint => namespace.gsub("/wsdl", "/action"),
        :controller_name => hash[:name],
        :endpoint_url => "#{request.protocol}#{request.host_with_port}/#{hash[:name]}/doc",
        :namespace_url => "#{request.protocol}#{request.host_with_port}/#{hash[:name]}/wsdl"
        }
    end


    render :template => "wash_with_html/all_services", :layout => false,
      :content_type => 'text/html'

  end


  private


end
