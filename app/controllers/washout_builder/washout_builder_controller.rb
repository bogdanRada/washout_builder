require_relative '../../../lib/washout_builder/document/generator'
module WashoutBuilder
  # controller that is used to prit all available services or print the documentation for a specific service
  class WashoutBuilderController < ActionController::Base
    protect_from_forgery
    around_action :check_env_available


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
      params[:name] = params[:defaults][:name] if params[:defaults].present?
      find_all_routes
      route_details = params[:name].present? ? controller_is_a_service?(params[:name]) : nil
      if route_details.present? && defined?(controller_class(params[:name]))
        @document = WashoutBuilder::Document::Generator.new(route_details, controller_class(params[:name]).controller_path)
        render template: 'wash_with_html/doc', layout: false,
        content_type: 'text/html'
      elsif
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
      @map_controllers = map_controllers { |hash| hash }
      @map_controllers.blank? ? [] : @map_controllers.map do |hash|
        controller_name = hash[:route].present? && hash[:route].respond_to?(:defaults) ? hash[:route].defaults[:controller] : nil
        if controller_name.present?
          {
            'service_name' => controller_naming(controller_name),
            'namespace' => service_namespace(hash, controller_name),
            'endpoint' => service_endpoint(hash, controller_name),
            'documentation_url' => service_documentation_url(hash, controller_name)
          }
        end
      end
    end

    def generate_wsdl_action
      '_generate_wsdl'
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
      route.defaults[:action] == generate_wsdl_action
    end

    def find_all_routes
      # get the controller and set the action for redirection
      engines = [Rails.application]
      engines.concat(::Rails::Engine.subclasses)

      routes = engines.each_with_object([]) do |engine, routes_array|
        engine_route = Rails.application.routes.named_routes[engine.engine_name]
        routes_hash_array = engine.routes.routes.map { |route|
          {
            engine: engine,
            route_set: engine.routes,
            route: route,
            mounted_at: engine_route.blank? ? nil : engine_route.path.spec.to_s
          }
        }

        routes_array.concat(routes_hash_array)
      end

      #routes = routes.sort_by { |hash| hash[:route].precedence }
      @routes = routes
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
    def map_controllers(action = 'select')
      res = @routes.send(action) do |hash|
        if hash[:route].present? && route_can_generate_wsdl?(hash[:route])
          yield hash if hash.present? && block_given?
        end
      end
      res = res.compact.uniq{|hash| hash[:route] } if action == 'select'
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
      map_controllers('detect') do |hash|
        if hash[:route].present? && hash[:route].respond_to?(:defaults)
          controller_naming(hash[:route].defaults[:controller]) == controller_naming(controller)
        end
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

    def route_helpers(hash)
      hash[:route_set].url_helpers
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
    def service_namespace(hash, controller_name)
      #controller_class(controller_name).soap_config.namespace
      route_helpers(hash).url_for(controller: controller_name, action: generate_wsdl_action, only_path: true)
    end

    # the endpoint is based on the namespace followed by /action suffix
    # @see #service_namespace
    #
    # @param [String] controller_name The name of the controller
    # @return [String] The endpoint of the web service
    # @api private
    def service_endpoint(hash, controller_name)
      service_namespace(hash, controller_name).gsub('/wsdl', '/action')
    end

    # constructs the documentation url for a specific web service
    #
    # @param [String] controller_name The name of the controller
    # @return [String] The documentation url for the web service ( relative to base url)
    # @api private
    def service_documentation_url(hash, controller_name)
      service_namespace(hash, controller_name).gsub('/wsdl', '/soap_doc')
      #"#{washout_builder.root_path}#{controller_naming(controller_name)}"
    end

    def check_env_available
      env_checker = WashoutBuilder::EnvChecker.new(Rails.application)
      if env_checker.available_for_env?(Rails.env)
        yield
      else
        render :nothing => true, content_type: 'text/html'
      end
    end

  end
end
