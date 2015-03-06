module WashoutBuilder
  class Type
    BASIC_TYPES = %w(string integer double boolean date datetime float time int)

    def self.all_fault_classes
      faults = []
      faults << WashOut::SOAPError if defined?(WashOut::SOAPError)
      faults << WashOut::Dispatcher::SOAPError if defined?(WashOut::Dispatcher::SOAPError)
      faults << SOAPError if defined?(SOAPError)
      faults
    end

    def self.ancestor_fault?(fault_class)
      fault_class.ancestors.find { |fault| all_fault_classes.include?(fault) }.present?
    end

    def self.valid_fault_class?(fault)
      fault.is_a?(Class) && (ancestor_fault?(fault) || all_fault_classes.include?(fault))
    end
  end
end
