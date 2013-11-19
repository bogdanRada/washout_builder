require 'active_support/concern'

module WashoutDoc
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::SOAP

    
    included do
      include WashOut::Configurable
      include WashoutDoc::Dispatcher
      self.soap_actions = {}
    end
  end
end
