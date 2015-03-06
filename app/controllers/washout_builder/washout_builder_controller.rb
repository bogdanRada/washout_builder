require_relative '../../../lib/washout_builder/document/generator'
module WashoutBuilder
  class WashoutBuilderController < ActionController::Base
    protect_from_forgery

    # Will show all api services if no name parameter is receiverd
    # If a name parameter is present wiill try to use that and find a controller
    # that was that name by camelcasing the name .
    # IF a name is provided will show the documentation page for that controller
    def all
      route = params[:name].present? ? controller_is_a_service?(params[:name]) : nil
      if route.present?
        @document = WashoutBuilder::Document::Generator.new(route.defaults[:controller])
        render template: 'wash_with_html/doc', layout: false,
               content_type: 'text/html'
      else
        all_services
      end
    end

  private

    # tries to find all services by searching through the rails controller
    # and returns their namespace, endpoint and a documentation url
    def all_services
      @map_controllers = map_controllers { |route| route.defaults[:controller] }
      @services = @map_controllers.blank? ? [] : @map_controllers.map do |controller_name|
        {
          'service_name' => controller_naming(controller_name),
          'namespace' => service_namespace(controller_name),
          'endpoint' => service_endpoint(controller_name),
          'documentation_url' => service_documentation_url(controller_name)
        }
      end

      render template: 'wash_with_html/all_services', layout: false,
             content_type: 'text/html'
    end

    # the way of converting from controller string in downcase in camelcase
    def controller_naming(controller)
      controller.camelize
    end

    # checking if a route has the action for generating WSDL
    def route_can_generate_wsdl?(route)
      route.defaults[:action] == '_generate_wsdl'
    end

    # method for getting all controllers that have the generate wsdl action or finding out
    # if a single controller is a soap service
    def map_controllers(action = 'map')
      res = Rails.application.routes.routes.send(action) do |route|
        if route_can_generate_wsdl?(route)
          yield route if block_given?
        end
      end
      res = res.uniq.compact if action == 'map'
      res
    end

    # checking if a controller is a soap service
    def controller_is_a_service?(controller)
      map_controllers('detect') do |route|
        controller_naming(route.defaults[:controller]) == controller_naming(controller)
      end
    end

    # getting the controller class from the controller string
    def controller_class(controller)
      controller_naming("#{controller}_controller").constantize
    end

    # retrieves the service namespace
    def service_namespace(controller_name)
      controller_class(controller_name).soap_config.namespace
    end

    # the endpoint is based on the namespace followed by /action suffix
    def service_endpoint(controller_name)
      service_namespace(controller_name).gsub('/wsdl', '/action')
    end

    # constructs the documentation url for a specific web service
    def service_documentation_url(controller_name)
      "#{washout_builder.root_url}#{controller_naming(controller_name)}"
    end
  end
end
