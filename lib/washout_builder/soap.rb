require 'active_support/concern'

module WashoutBuilder
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::SOAP
  
    
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
        
          current_action[:input] = WashoutBuilder::Param.parse_def(soap_config, options[:args])
          current_action[:output] = WashoutBuilder::Param.parse_def(soap_config, options[:return])
          current_action[:description] = options[:description]
          current_action[:raises] = options[:raises]
        
      end
    end
    

    included do
      include WashOut::Configurable
      include WashoutBuilder::Dispatcher
      self.soap_actions = {}
    end
  end
end
