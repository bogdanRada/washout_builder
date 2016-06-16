require_relative '../../../lib/washout_builder/document/generator'
module WashoutBuilder
  # controller that is used to prit all available services or print the documentation for a specific service
  class WashoutBuilderController < ActionController::Base
    protect_from_forgery

    # Will show all api services if no name parameter is receiverd
    # If a name parameter is present will try to use that and find a controller
    # that was that name by camelcasing the name .
    # IF a name is provided will show the documentation page for that controller
    # @see #all_services
    # @see WashoutBuilder::Document::Generator#new
    #
    # @return [void]
    #
    # @api public
    def all
      find_all_routes
      route = params[:name].present? ? controller_is_a_service?(params[:name]) : nil
      if route.present?
        @document = WashoutBuilder::Document::Generator.new(route.defaults[:controller])
        render template: 'wash_with_html/doc', layout: false,
               content_type: 'text/html'
      else
        @services = all_services
        render template: 'wash_with_html/all_services', layout: false,
               content_type: 'text/html'
      end
    end

  private

    # tries to find all services by searching through the rails controller
    # and returns their namespace, endpoint and a documentation url
    # @see map_controllers
    #
    #
    # @return [Hash] options The hash that contains all information about available services
    # @option options [String] :service_name (@see #controller_naming)  The name of the controller that is a  soap servive
    # @option options [String]:namespace (@see #service_namespace ) The namespace of the soap service for that controller
    # @option options [String] :endpoint (@see #service_endpoint ) The endpoint of the service controller
    # @option options [String] :documentation_url (@see #service_documentation_url ) The url where the documentation can be seen in HTML
    # for that service controller
    #
    # @api private
    def all_services
      @map_controllers = map_controllers { |route| route.defaults[:controller] }
      @map_controllers.blank? ? [] : @map_controllers.map do |controller_name|
        {
          'service_name' => controller_naming(controller_name),
          'namespace' => service_namespace(controller_name),
          'endpoint' => service_endpoint(controller_name),
          'documentation_url' => service_documentation_url(controller_name)
        }
      end
    end

    # the way of converting from controller string in downcase in camelcase
    # @param [String] controller  The controller name in downcase letter
    #
    # @return [String] The controller name in camelcase letters
    #
    # @api private
    def controller_naming(controller)
      controller.camelize
    end

    # checking if a route has the action for generating WSDL
    # @param [ActionDispatch::Journey::Route] route The route that is used to check if can respond to _generate_wsdl action
    #
    # @return [Boolean] Returns true if the route can respond to _generate_wsdl action
    #
    # @api private
    def route_can_generate_wsdl?(route)
      route.defaults[:action] == '_generate_wsdl'
    end

    def find_all_routes
      rails_routes = Rails.application.routes.routes.map { |route| route }
      engine_routes = []
      ::Rails::Engine.subclasses.each do |engine|
        engine.routes.routes.each do |route|
          engine_routes << route
        end
      end
      @routes = rails_routes.concat(engine_routes).uniq.compact
      @routes
    end

    # method for getting all controllers that have the generate wsdl action or finding out
    # if a single controller is a soap service
    # @see #route_can_generate_wsdl?
    #
    # @param [String] action The action is used to collect or find a particular route . Can only be *map* or *detect*
    #
    # @yield [ActionDispatch::Journey::Route] yield each route to the block while iterating through the routes
    #
    # @return [ActionDispatch::Journey::Route, Array<ActionDispatch::Journey::Route>] Can return either a collection of routes or a single route depending on the action
    #
    # @api private
    def map_controllers(action = 'map')
      res = @routes.send(action) do |route|
        if route_can_generate_wsdl?(route)
          yield route if block_given?
        end
      end
      res = res.uniq.compact if action == 'map'
      res
    end

    # checking if a controller is a soap service
    # @see #map_controllers
    # @see #controller_naming
    #
    # @param [String] controller The controller that is used to check if it is soap service
    #
    # @return [Boolean] Returns true if we find a route that can generate wsdl and the name of the route matches the name of the controller
    #
    # @api private
    def controller_is_a_service?(controller)
      map_controllers('detect') do |route|
        controller_naming(route.defaults[:controller]) == controller_naming(controller)
      end
    end

    # getting the controller class from the controller string
    # @see #controller_naming
    #
    # @param [String] controller The name of the controller
    # @return [Class] the original controller class name
    # @api private
    def controller_class(controller)
      controller = controller.gsub(/\/+/, '/')
      controller_naming("#{controller}_controller").constantize
    end

    # retrieves the service namespace
    # @see #controller_class
    #
    # the method receives the controlle name than will try to find the class  name
    # of the controller and use the soap configuration of the class to
    # retrive the namespace of the soap service
    #
    # @param [String] controller_name The name of the controller
    # @return [String] The namespace of the soap service that is used in that controller
    #
    # @api private
    def service_namespace(controller_name)
      controller_class(controller_name).soap_config.namespace
    end

    # the endpoint is based on the namespace followed by /action suffix
    # @see #service_namespace
    #
    # @param [String] controller_name The name of the controller
    # @return [String] The endpoint of the web service
    # @api private
    def service_endpoint(controller_name)
      service_namespace(controller_name).gsub('/wsdl', '/action')
    end

    # constructs the documentation url for a specific web service
    #
    # @param [String] controller_name The name of the controller
    # @return [String] The documentation url for the web service ( relative to base url)
    # @api private
    def service_documentation_url(controller_name)
      "#{washout_builder.root_url}#{controller_naming(controller_name)}"
    end
  end
end
