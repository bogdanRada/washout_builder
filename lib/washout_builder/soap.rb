require 'active_support/concern'

module WashoutBuilder
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::SOAP if defined?(WashOut::SOAP)
    include WashOut::Rails::Controller if defined?(WashOut::Rails::Controller)
  
    
      module ClassMethods
       
      # Define a SOAP action +action+. The function has two required +options+:
      # :args and :return. Each is a type +definition+ of format described in
      # WashOut::Param#parse_def.
      #
      # An optional option :to can be passed to allow for names of SOAP actions
      # which are not valid Ruby function names.
      def soap_action(action, options={})
          original_soap_action(action, options)
          
          current_action = self.soap_actions[action]
        
          current_action[:input] = WashOut::Param.parse_builder_def(soap_config, options[:args])
          current_action[:output] = WashOut::Param.parse_builder_def(soap_config, options[:return])
         
      end
    end
    

    included do
      include WashOut::Configurable if defined?(WashOut::Configurable)
      include  WashOut::Dispatcher if defined?(WashOut::Dispatcher)
      include WashoutBuilder::Dispatcher
      self.soap_actions = {}
    end
  end
end
