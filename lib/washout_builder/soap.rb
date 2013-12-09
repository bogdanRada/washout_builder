require 'active_support/concern'

module WashoutBuilder
  module SOAP
    extend ActiveSupport::Concern
    include WashOut::Rails::Controller 
    
    


    included do
      include WashoutBuilder::Dispatcher
    end
  end
end
