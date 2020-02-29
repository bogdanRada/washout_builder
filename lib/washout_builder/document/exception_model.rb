require_relative './shared_complex_type'
module WashoutBuilder
  module Document
    # the class that is used for soap exceptions to build structure and find ancestors and descendants
    module ExceptionModel
      extend ActiveSupport::Concern
      include WashoutBuilder::Document::SharedComplexType

      def self.included(base)
        base.send :include, WashoutBuilder::Document::SharedComplexType
      end

      # A recursive function that retrives all the ancestors of the current exception class
      # @see #fault_ancestors
      # @see #fault_ancestor_hash
      # @see #find_fault_model_structure
      # @see #fault_without_inheritable_elements
      #
      # @param [Array<Hash>] classes_defined An array that contains all the information about all the exception classes found so far
      # @param [Boolean] _debug = false An optional parameter used for debugging purposes
      # @return [Array<Class>] Array with all the exception classes from which the current exception class inherits from
      # @api public
      def get_fault_class_ancestors(classes_defined, _debug = false)
        bool_the_same = false
        ancestors = fault_ancestors
        if ancestors.blank?
          classes_defined << fault_ancestor_hash(find_fault_model_structure, [])
        else
          classes_defined << fault_ancestor_hash(fault_without_inheritable_elements(ancestors), ancestors)
          ancestors[0].get_fault_class_ancestors(classes_defined)
        end
        ancestors unless bool_the_same
      end

      # Removes the inheritable elements from current object that are inherited from the class send as argument
      # @see #remove_fault_type_inheritable_elements
      #
      # @param [Class] ancestors describe ancestors
      # @return [Type] description of returned object
      # @api public
      def fault_without_inheritable_elements(ancestors)
        remove_fault_type_inheritable_elements(ancestors[0].find_fault_model_structure.keys)
      end

      # Retrieves all the ancestors of the current exception class except ActiveRecord::Base', 'Object', 'BasicObject', 'Exception'
      #
      # @return [Array<Class>] Returns an array with all the classes from which the current exception class inherits from
      # @api public
      def fault_ancestors
        get_complex_type_ancestors(self, %w(ActiveRecord::Base Object BasicObject Exception))
      end

      # constructs the structure of the current exception class by holding the instance, the structure, and its ancestors
      #
      # @param [Hash] structure A hash that contains the structure of the current exception class (@see #find_fault_model_structure)
      # @param [Array<Class>] ancestors An array with all the exception classes from which the current object inherits from
      # @return [Hash]  options The hash that contains information about the current exception class
      # @option options [WashoutBuilder::Document::ExceptionModel] :fault The current exception class that extends WashoutBuilder::Document::ExceptionModel
      # @option options [Hash]:structure An hash that contains as keys the atribute names and as value the primitive and member type of that attributre
      # @option options [Array<Class>] :ancestors An array with all the classes from which current class is inheriting from
      # @api public
      def fault_ancestor_hash(structure, ancestors)
        { fault: self, structure: structure, ancestors: ancestors }
      end

      # Removes the atributes that are send as argument
      # @see #find_fault_model_structure
      #
      # @param [Array<String>] keys The keys that have to be removed from the model structure
      # @return [Hash] An hash that contains as keys the atribute names and as value the primitive and member type of that attribute
      # @api public
      def remove_fault_type_inheritable_elements(keys)
        find_fault_model_structure.delete_if { |key, _value| keys.include?(key) }
      end

      # Dirty hack to determine if a method has both a setter and a getter and not basic method inherited from Object class
      #
      # @param [String] method The method thats needs to be verified
      # @return [Boolean] Returns true  if current class responds to the method and  has both a setter and a getter for that method and the method is not inherited from Object class
      # @api public
      def check_valid_fault_method?(method)
        method != :== && method != :! &&
            (instance_methods.include?(:"#{method}=") ||
                instance_methods.include?(:"#{method}")
            )
      end

      # tries to fins all instance methods that have both a setter and a getter of the curent class
      # @see #check_valid_fault_method?
      # @return [Array<String>] An array with all the atrributes and instance methods that have both a setter and a getter
      # @api public
      def find_fault_attributes
        attrs = instance_methods(nil).map do |method|
          method.to_s if check_valid_fault_method?(method)
        end
        attrs = attrs.delete_if { |method| method.end_with?('=') && attrs.include?(method.delete('=')) }
        attrs.concat(%w(message backtrace))
      end

      # Dirty hack to get the type of an atribute. Considering all other attributes as string type
      #
      # @param [String] method_name The name of the attribute to use
      # @return [String] Returns the type of the attribute , Currently returns "integer" for attribute "code" and "string" for all others
      # @api public
      def get_fault_type_method(method_name)
        case method_name.to_s.downcase
        when 'code'
          'integer'
        when 'message', 'backtrace'
          'string'
        else
          'string'
        end
      end

      # Description of method
      # @see #find_fault_attributes
      # @see #get_fault_type_method
      #
      # @return [Hash] An hash that contains as keys the atribute names and as value the primitive and member type of that attribute
      # @api public
      def find_fault_model_structure
        h = {}
        find_fault_attributes.each do |method_name|
          method_name = method_name.to_s.end_with?('=') ? method_name.to_s.delete('=') : method_name
          primitive_type = get_fault_type_method(method_name)
          h["#{method_name}"] = {
              primitive: "#{primitive_type}",
              member_type: nil
          }
        end
        h
      end
    end
  end
end
