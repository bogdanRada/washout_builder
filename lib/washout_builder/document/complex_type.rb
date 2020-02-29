require_relative './shared_complex_type'
module WashoutBuilder
  # namespace of the class
  module Document
    #  class that is used for current Washout::Param object to know his complex type name and structure and detect ancestors and descendants
    module ComplexType
      extend ActiveSupport::Concern
      include WashoutBuilder::Document::SharedComplexType

      # finds the complex class name of the current Washout::Param object and checks if is a duplicate
      # @see #check_duplicate_complex_class
      #
      # @param [Array] classes_defined Array that is used for when iterating through descendants and ancestors
      #
      # @return [Class] the complex type name of the current object
      #
      # @api public
      def find_complex_class_name(classes_defined = [])
        complex_class = struct? ? basic_type.tr('.', '/').camelize : nil
        check_duplicate_complex_class(classes_defined, complex_class) unless complex_class.nil? || classes_defined.blank?
        complex_class
      end

      # checks if the complex class appears in the array of complex types
      #
      # @param [Array<Hash>] classes_defined Array that is used for checking if a complex type is already classes_defined
      # @param [Class] complex_class the complex type name used for searching
      #
      # @return [Boolean] returns true or false if the complex type is found inside the array
      # @raise [RuntimeError] Raises a runtime error if is detected a duplicate use of the complex type
      # @api public
      def check_duplicate_complex_class(classes_defined, complex_class)
        complex_obj_found = classes_defined.find { |hash| hash[:class] == complex_class }
        raise "Duplicate use of `#{basic_type}` type name. Consider using classified types." if !complex_obj_found.nil? && struct? && !classified?
      end

      # finds the complex class ancestors if the current object is classified, otherwise returns nil
      # @see WashOut::Param#classified?
      # @see #get_class_ancestors
      #
      # @param [WashOut::SoapConfig] config the configuration of the soap service
      # @param [Clas] complex_class  the complex type name of the object
      # @param [Array<Hash>] classes_defined An array that holds all the complex types found so far
      #
      # @return [Array<Class>, nil] returns nil if object not classified othewise an array of classes that are ancestors to curent object
      #
      # @api public
      def complex_type_ancestors(config, complex_class, classes_defined)
        classified? ? get_class_ancestors(config, complex_class, classes_defined) : nil
      end

      # iterates through all the elements of the current object
      # and constructs a hash that has as keys the element names and as value their type

      # @return [Hash] THe hash that contains information about the structure of the current object as complex type
      # @api public
      def find_param_structure
        map.each_with_object({}) do|item, memo|
          memo[item.name] = item.type
          memo
        end
      end

      # removes from this current object the elements that are inherited from other objects
      # and set the map of the curent object to the new value
      #
      # @param [Array<String>] keys An array with the keys that need to be removed from current object
      # @return [void]
      # @api public
      def remove_type_inheritable_elements(keys)
        self.map = map.delete_if { |element| keys.include?(element.name) }
      end

      # Dirty hack to fix the first washout param type.
      # This only applies if the first complex type is inheriting WashOutType
      # its name should be set to its descendant  and the map of the current object will be set to its descendant
      # @see  WashOut::Param#parse_builder_def
      #
      # @param [WashOut::SoapConfig] config an object that holds the soap configuration
      # @param [Class, String] complex_class the name of the complex type either as a string or a class
      # @return [void]
      # @api public
      def fix_descendant_wash_out_type(config, complex_class)
        param_class = find_class_from_string(complex_class)
        base_param_class = WashoutBuilder::Type.base_param_class
        base_type_class =  WashoutBuilder::Type.base_type_class
        return if base_param_class.blank? || base_type_class.blank?
        return unless param_class.present? && param_class.ancestors.include?(base_type_class) && map[0].present?
        descendant = base_param_class.parse_builder_def(config, param_class.wash_out_param_map)[0]
        self.name = descendant.name
        self.map = descendant.map
      end

      # Description of method
      #
      # @param [String] complex_class A string that contains the name of a class
      # @return [Class, nil] returns the class if it is classes_defined otherwise nil
      # @api public
      def find_class_from_string(complex_class)
        complex_class.is_a?(Class) ? complex_class : complex_class.constantize
      rescue
        nil
      end

      # Method that is used to check if the current object has exactly same structure as one of his ancestors
      # if it is true, will return true, otherwise will first remove the inheritated elements from his ancestor and then return false
      # @see #find_param_structure
      # @see #remove_type_inheritable_elements
      #
      # @param [WasOut::Param] ancestor The complex type that is used to compare to the current complex type
      # @return [Boolean] returns true if both objects have same structure, otherwise will first remove the inheritated elements from his ancestor and then return false
      # @api public
      def same_structure_as_ancestor?(ancestor)
        param_structure = find_param_structure
        ancestor_structure = ancestor.find_param_structure
        if param_structure.keys == ancestor_structure.keys
          true
        else
          remove_type_inheritable_elements(ancestor_structure.keys)
          false
        end
      end

      # Mehod that is used to get the ancestors of the current complex type
      # the method will not filter the results by rejecting the classes 'ActiveRecord::Base', 'Object', 'BasicObject', 'WashOut::Type'
      # @see WashoutBuilder::Document::SharedComplexType#get_complex_type_ancestors
      #
      # @param [Class, String] class_name the name of the on object that is used to fetch his ancestors
      # @return [Array<Class>] Returns an array with all the classes from each the object inherits from but filters the results and removes the classes
      #  'ActiveRecord::Base', 'Object', 'BasicObject', 'WashOut::Type'
      # @api public
      def get_ancestors(class_name)
        param_class = find_class_from_string(class_name)
        if param_class.nil?
          nil
        else
          base_type_class =  WashoutBuilder::Type.base_type_class
          filtered_classes = %w(ActiveRecord::Base Object BasicObject)
          filtered_classes << base_type_class.to_s if base_type_class.present?
          get_complex_type_ancestors(param_class, filtered_classes)
        end
      end

      # Method used to fetch the descendants of the current object
      # @see #get_nested_complex_types
      # @see WashOutParam#struct?
      #
      # @param [WashOut::SoapConfig] config an object that holds the soap configuration
      # @param [Array<Hash>] classes_defined An Array with all the complex types that have been detected till now
      # @return [Array<Hash>] An array with all the complex types that
      # @api public
      def complex_type_descendants(config, classes_defined)
        if struct?
          c_names = []
          map.each { |obj| c_names.concat(obj.get_nested_complex_types(config, classes_defined)) }
          classes_defined.concat(c_names)
        end
        classes_defined
      end

      # Recursive method that tries to identify all the nested descendants of the current object
      # @see #find_complex_class_name
      # @see #fix_descendant_wash_out_type
      # @see #complex_type_hash
      # @see #complex_type_ancestors
      # @see #complex_type_descendants
      #
      # @param [WashOut::SoapConfig] config holds the soap configuration
      # @param [Array<Hash>] classes_defined An array with all the complex type structures that have been detected so far
      # @return [Array<Hash>] An array with all the complex type that have been detected while iterating to all the descendants of the current object and also contains the previous ones
      # @api public
      def get_nested_complex_types(config, classes_defined)
        classes_defined = [] if classes_defined.blank?
        complex_class = find_complex_class_name(classes_defined)
        fix_descendant_wash_out_type(config, complex_class)
        unless complex_class.nil?
          classes_defined << complex_type_hash(complex_class, self, complex_type_ancestors(config, complex_class, classes_defined))
        end
        classes_defined = complex_type_descendants(config, classes_defined)
        classes_defined.blank? ? [] : classes_defined.sort_by { |hash| hash[:class].to_s.downcase }.uniq
      end

      # method that constructs the a hash with the name of the ancestor ( the class name) and as value its elemen structure
      # @see WashOut::Type#wash_out_param_map
      #
      # @param [WashoutType] ancestors The class that inherits from WashoutType
      # @return [Hash] A hash that has as a key the class name in downcase letters and as value the mapping of the class attributes
      # @api public
      def ancestor_structure(ancestors)
        { ancestors[0].to_s.downcase => ancestors[0].wash_out_param_map }
      end

      # Constructs the complex type information wuth its name, with the object itself and his ancestors
      #
      # @param [Class] class_name The name of the class
      # @param [WashOut::Param] object The object itself
      # @param [Array<Class>] ancestors An array with all the ancestors that the object inherits from
      # @return [Hash] A hash with that contains the params sent to the method
      # @api public
      def complex_type_hash(class_name, object, ancestors)
        {
            class: class_name,
            obj: object,
            ancestors: ancestors
        }
      end

      # A recursive method that fetches the ancestors of a given class (that inherits from WashoutType)
      # @see #get_ancestors
      # @see  WashOut::Param#parse_def
      # @see #same_structure_as_ancestor?
      # @see #complex_type_hash
      #
      # @param [WashOut::SoapConfig] config holds the soap configuration
      # @param [Class] class_name  The name of the class that is used for fetching the ancestors
      # @param [Array<Hash>] classes_defined An Array with all the complex types that have been detected so far
      # @return [Array<Class>] An Array of classes from which the class that is sent as parameter inherits from
      # @api public
      def get_class_ancestors(config, class_name, classes_defined)
        ancestors = get_ancestors(class_name)
        return if ancestors.blank?
        base_param_class = WashoutBuilder::Type.base_param_class
        return if base_param_class.blank?
        ancestor_object = base_param_class.parse_def(config, ancestor_structure(ancestors))[0]
        bool_the_same = same_structure_as_ancestor?(ancestor_object)
        unless bool_the_same
          top_ancestors = get_class_ancestors(config, ancestors[0], classes_defined)
          classes_defined << complex_type_hash(ancestors[0], ancestor_object, top_ancestors)
        end
        ancestors unless bool_the_same
      end
    end
  end
end
