require 'active_support/concern'

module WashoutBuilder
  # the module that is used for soap actions to parse their definition and hold the infoirmation about
  # their arguments and return types
  module SOAP
    extend ActiveSupport::Concern
    included do
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
  end
end
