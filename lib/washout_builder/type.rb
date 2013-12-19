module WashoutBuilder
  class Type 

    BASIC_TYPES=[
      "string",
      "integer",
      "double",
      "boolean",
      "date",
      "datetime",
      "float",
      "time",
      "int"
    ]

    def self.get_fault_classes
      faults = []
      faults << WashOut::SOAPError if defined?(WashOut::SOAPError)
      faults << WashOut::Dispatcher::SOAPError if defined?(WashOut::Dispatcher::SOAPError)
      faults << SOAPError if defined?(SOAPError)
      return faults
    end
    
    
  end
end
