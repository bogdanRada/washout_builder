module WashoutBuilder
  # class that is used to define the basic types and the basic exception classes that should be considered
  class Type
    # the basic types that are considered when checking an object type
    BASIC_TYPES = %w(string integer double boolean date datetime float time int)

    # returns all the exception classes that should be considered to be detected
    #
    # @return [Array<Class>] returns all the exception classes that should be considered to be detected
    # @api public
    def self.all_fault_classes
      faults = []
      faults << WashOut::SOAPError if defined?(WashOut::SOAPError)
      faults << WashOut::Dispatcher::SOAPError if defined?(WashOut::Dispatcher::SOAPError)
      faults << SOAPError if defined?(SOAPError)
      faults
    end

    # Checks if a exception class inherits from the basic ones
    # @see #all_fault_classes
    #
    # @param [Class] fault_class the exception class that needs to be checks if has as ancestor one of the base classes
    # @return [Boolean] Returns true if the class inherits from the basic classes or false otherwise
    # @api public
    def self.ancestor_fault?(fault_class)
      fault_class.ancestors.find { |fault| all_fault_classes.include?(fault) }.present?
    end

    # Checks if a exception class is valid, by checking if either is a basic exception class or has as ancerstor one ot the base classes
    #
    # @param [Class] fault The exception class that needs to be checks if has as ancestor one of the base classes or is one of them
    # @return [Boolean] Returns true if the class inherits from the basic classes or is one of them, otherwise false
    # @api public
    def self.valid_fault_class?(fault)
      fault.is_a?(Class) && (ancestor_fault?(fault) || all_fault_classes.include?(fault))
    end
  end
end
