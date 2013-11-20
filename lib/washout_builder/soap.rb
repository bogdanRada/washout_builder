require 'active_support/concern'

module WashoutBuilder
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::SOAP


    included do
      include WashOut::Configurable
      include WashoutBuilder::Dispatcher
      self.soap_actions = {}
    end
  end
end
