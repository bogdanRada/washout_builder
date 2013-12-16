module WashoutBuilder
  module Document
    module Fault
      extend WashoutBuilder::Document::VirtusModel
      include Virtus.model
      attribute :code, Integer
      attribute :message, String
      attribute :backtrace, String
      
    end
  end
end
