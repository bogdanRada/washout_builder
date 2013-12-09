require 'active_support/concern'

module WashoutBuilder
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::SOAP if defined?(WashOut::SOAP)
    include WashOut::Rails::Controller if defined?(WashOut::Rails::Controller)
  
    
    

    included do
      include WashOut::Configurable if defined?(WashOut::Configurable)
      include  WashOut::Dispatcher if defined?(WashOut::Dispatcher)
      include WashoutBuilder::Dispatcher
      self.soap_actions = {}
    end
  end
end
