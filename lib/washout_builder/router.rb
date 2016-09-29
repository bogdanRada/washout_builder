module WashoutBuilder
  # This class is a Rack middleware used to route SOAP requests to a proper
  # action of a given SOAP controller.
  class Router

    def initialize(controller_path)
      @controller_path = controller_path
    end

    def call(env)
      env['washout_builder.controller_path'] = @controller_path
      WashoutBuilderController.action(:all).call(env)
    end

  end
end
