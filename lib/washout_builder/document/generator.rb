require_relative './exception_model'
module WashoutBuilder
  module Document
    # class that is used to generate HTML documentation for a soap service
    class Generator
      # class that is used to generate HTML documentation for a soap service
      #
      # @!attribute soap_actions
      #   @return [Hash] Hash that contains all the actions to which the web service responds to and information about them
      #
      # @!attribute config
      #   @return [WashOut::SoapConfig] holds the soap configuration for the soap service
      #
      # @!attribute controller_name
      #   @return [String] The name of the controller that acts like a soap service
      attr_accessor :soap_actions, :config, :controller_name

      # Method used to initialize the instance of object
      # @see #controller_class
      #
      # @param [String] controller The name of the controller that acts like a soap service
      # @return [void]
      # @api public
      def initialize(controller)
        controller_class_name = controller_class(controller)
        self.config = controller_class_name.soap_config
        self.soap_actions = controller_class_name.soap_actions
        self.controller_name = controller
      end

      # Returns the namespace used for the controller by using the soap configuration of the controller
      #
      # @return [String] description of returned object
      # @api public
      def namespace
        config.respond_to?(:namespace) ? config.namespace : nil
      end

      # Retrives the class of the controller by using its name
      #
      # @param [String] controller The name of the controller
      # @return [Class] Returns the class of the controller
      # @api public
      def controller_class(controller)
        "#{controller}_controller".camelize.constantize
      end

      # Retrieves the endpoint of the soap service based on its namespace
      # @see #namespace
      #
      # @return [String] Returns the current soap service's endpoint based on its namespace
      # @api public
      def endpoint
        namespace.blank? ? nil : namespace.gsub('/wsdl', '/action')
      end

      # Returns the service name using camelcase letter
      #
      # @return [String] Returns the service name using camelcase letter
      # @api public
      def service
        controller_name.blank? ? nil : controller_name.camelize
      end

      # Returns the service description if the service can respond to description method
      #
      # @return [String] Returns the service description if the service can respond to description method
      # @api public
      def service_description
        config.respond_to?(:description) ? config.description : nil
      end

      # Returns the service arguments description if the service can respond to args_description method
      #
      # @return [String] Returns the service arguments description if the service can respond to args_description method
      # @api public
      def service_args_description
        config.respond_to?(:args_description) ? config.args_description : nil
      end

      #  returns a collection of all operation that the service responds to
      #
      # @return [Array<String>]  returns a collection of all operation that the service responds to
      # @api public
      def operations
        soap_actions.map { |operation, _formats| operation }
      end

      # returns the operations of a service by sorting them alphabetically and removes duplicates
      #
      # @return [Array<String>]  returns a collection of all operation that the service responds to sorted alphabetically
      # @api public
      def sorted_operations
        soap_actions.sort_by { |operation, _formats| operation.downcase }.uniq unless soap_actions.blank?
      end

      # Returns the exceptions that a specific operation can raise
      #
      # @param [String] operation_name describe operation_name
      # @return [Array<Class>]  returns an array with all the exception classes that the operation send as argument can raise
      # @api public
      def operation_exceptions(operation_name)
        hash_object = soap_actions.find { |operation, _formats| operation.to_s.downcase == operation_name.to_s.downcase }
        return if hash_object.blank?
        faults = hash_object[1][:raises]
        faults = faults.is_a?(Array) ? faults : [faults]
        faults.select { |x| WashoutBuilder::Type.valid_fault_class?(x) }
      end

      # Sorts a hash by a key alphabetically
      #
      # @param [Hash] types Any kind of hash
      #  @option types [String, Symbol] :type The name of the key should be the same as the second argument
      # @param [String, Symbol] type The key that is used for sorting alphabetically
      # @return [Hash] options Same hash sorted alphabetically by the specified key and without duplicates
      #  @option options [String, Symbol] :type The name of the key should be the same as the second argument
      # @api public
      def sort_complex_types(types, type)
        types.sort_by { |hash| hash[type.to_sym].to_s.downcase }.uniq { |hash| hash[type.to_sym] } unless types.blank?
      end

      # Returns either the input arguments of a operation or the output types of that operation depending on the argument
      #
      # @param [String] type The type of the arguments that need to be returned ("input" or anything else )
      # @return [Array<WashOutParam>, Array<Error>] If the argument is "input" will return the arguments of the operation , ottherwise the return type
      # @api public
      def argument_types(type)
        format_type = (type == 'input') ? 'builder_in' : 'builder_out'
        types = []
        unless soap_actions.blank?
          soap_actions.each do |_operation, formats|
            (formats[format_type.to_sym]).each do |p|
              types << p
            end
          end
        end
        types
      end

      # Returns the arguments of all operations
      # @see #argument_types
      # @return [Array<WashOut::Param>] An array with all the arguments types of all operations the service responds to
      # @api public
      def input_types
        argument_types('input')
      end

      # Returns the arguments of all operations
      # @see #argument_types
      # @return [Array<Error>] An array with all the exceptions that all operations can raise
      # @api public
      def output_types
        argument_types('output')
      end

      # Returns the names of all operations sorted alphabetically
      #
      # @return [Array<String>] An array with all the names of all operations sorted alphabetically
      # @api public
      def all_soap_action_names
        operations.map(&:to_s).sort_by(&:downcase).uniq unless soap_actions.blank?
      end

      # Returns all the complex types sorted alphabetically
      # @see WashoutBuilder::Document::ComplexType#get_nested_complex_types

      # @return [Array<WashOut::Param>] Returns an array with all the complex types sorted alphabetically
      # @api public
      def complex_types
        defined = []
        (input_types + output_types).each do |p|
          defined.concat(p.get_nested_complex_types(config, defined))
        end
        defined = sort_complex_types(defined, 'class')
      end

      # Returns an array with all the operations that can raise an exception at least or more
      #
      # @return [Array<String>] Returns an array with all the names of all operations that can raise an exception or more
      # @api public
      def actions_with_exceptions
        soap_actions.select { |_operation, formats| !formats[:raises].blank? }
      end

      # Returns all the exception raised by all operations
      # @see #actions_with_exceptions
      #
      # @return [Array<Class>] Returns an array with all the exception classes that are raised by all operations
      # @api public
      def exceptions_raised
        actions_with_exceptions.map { |_operation, formats| formats[:raises].is_a?(Array) ? formats[:raises] : [formats[:raises]] }.flatten
      end

      # Fiters the exceptions raised by checking if they classes inherit from WashOout::SoapError
      # @see #exceptions_raised
      # @return [Array<Class>] returns the exceptions that are raised by all operations filtering only the ones that inherit from WashOut::SoapError
      # @api public
      def filter_exceptions_raised
        exceptions_raised.select { |x| WashoutBuilder::Type.valid_fault_class?(x) } unless actions_with_exceptions.blank?
      end

      # Retuens all the exception classes that can be raised by all operations with their ancestors also
      # @see #filter_exceptions_raised
      # @see WashoutBuilder::Document::ExceptionModel#get_fault_class_ancestors
      #
      # @param [Array<Class>] base_fault_array An array with the base exception classes from which we try to identify their ancestors
      # @return [Array>Class>] Returns all the exception classes that can be raised by all operations with their ancestors also
      # @api public
      def get_complex_fault_types(base_fault_array)
        fault_types = []
        defined = filter_exceptions_raised
        defined = defined.blank? ? base_fault_array : defined.concat(base_fault_array)
        defined.each { |exception_class| exception_class.get_fault_class_ancestors(fault_types, true) } unless defined.blank?
        fault_types
      end

      # Returns all the exception classes raised by all operations sorted alphabetically
      # @see WashoutBuilder::Type#all_fault_classes
      # @see #get_complex_fault_types
      # @see #sort_complex_types
      #
      # @return [Array<Class>]  Returns all the exception classes that can be raised by all operations with their ancestors also sorted alphabetically
      # @api public
      def fault_types
        base_fault = [WashoutBuilder::Type.all_fault_classes.first]
        fault_types = get_complex_fault_types(base_fault)
        sort_complex_types(fault_types, 'fault')
      end
    end
  end
end
