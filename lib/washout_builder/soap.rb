require 'active_support/concern'

module WashoutBuilder
  # the module that is used for soap actions to parse their definition and hold the infoirmation about
  # their arguments and return types
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::SOAP if defined?(WashOut::SOAP)
    include WashOut::Rails::Controller if defined?(WashOut::Rails::Controller)

    # module that is used to define a soap action for a controller
    module ClassMethods
      # module that is used to define a soap action for a controller
      #
      # @!attribute soap_actions
      #   @return [Hash] Hash that contains all the actions to which the web service responds to and information about them
      #
      # @!attribute washout_builder_action
      #   @return [String] holds the action of the controller
      attr_accessor :soap_actions, :washout_builder_action

      # Define a SOAP action +action+. The function has two required +options+:
      # :args and :return. Each is a type +definition+ of format described in
      # WashOut::Param#parse_def.
      #
      # An optional option :to can be passed to allow for names of SOAP actions
      # which are not valid Ruby function names.
      # @param  [Symbol, Class]  action the action that is requested
      # @param [Hash] options  the options used for
      #
      # @return [void]
      #
      # @api public
      def soap_action(action, options = {})
        original_soap_action(action, options)

        if action.is_a?(Symbol)
          if soap_config.camelize_wsdl.to_s == 'lower'
            action = action.to_s.camelize(:lower)
          elsif soap_config.camelize_wsdl
            action = action.to_s.camelize
          end
        end

        current_action = soap_actions[action]
        current_action[:builder_in] = WashOut::Param.parse_builder_def(soap_config, options[:args])
        current_action[:builder_out] = WashOut::Param.parse_builder_def(soap_config, options[:return])
      end
    end

    included do
      include WashOut::Configurable if defined?(WashOut::Configurable)
      include WashOut::Dispatcher if defined?(WashOut::Dispatcher)
      self.soap_actions = {}
    end
  end
end
