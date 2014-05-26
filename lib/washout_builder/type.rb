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
    
      
    def self.has_ancestor_fault?(fault_class)
      fault_class.ancestors.detect{ |fault|  get_fault_classes.include?(fault)  }.present?
    end
      
    def self.valid_fault_class?(fault)
      fault.is_a?(Class) &&   ( has_ancestor_fault?(fault) ||  get_fault_classes.include?(fault)) 
    end
    
    
  end
end
