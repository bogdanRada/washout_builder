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
      # @param [Array] defined Array that is used for when iterating through descendants and ancestors
      #
      # @return [Class] the complex type name of the current object
      #
      # @api public
      def find_complex_class_name(defined = [])
        complex_class = struct? ? basic_type.tr('.', '/').camelize : nil
        check_duplicate_complex_class(defined, complex_class) unless complex_class.nil? || defined.blank?
        complex_class
      end

      # checks if the complex class appears in the array of complex types
      #
      # @param [Array<Hash>] defined Array that is used for checking if a complex type is already defined
      # @param [Class] complex_class the complex type name used for searching
      #
      # @return [Boolean] returns true or false if the complex type is found inside the array
      #
      # @api public
      def check_duplicate_complex_class(defined, complex_class)
        complex_obj_found = defined.find { |hash| hash[:class] == complex_class }
        raise "Duplicate use of `#{basic_type}` type name. Consider using classified types." if !complex_obj_found.nil? && struct? && !classified?
      end

      # finds the complex class ancestors if the current object is classified, otherwise returns nil
      # @see WashOut::Param#classified?
      # @see #get_class_ancestors
      #
      # @param [WashOut::SoapConfig] config the configuration of the soap service
      # @param [Clas] complex_class  the complex type name of the object
      # @param [Array<Hash>] defined An array that holds all the complex types found so far
      #
      # @return [Array<Class>, nil] returns nil if object not classified othewise an array of classes that are ancestors to curent object
      #
      # @api public
      def complex_type_ancestors(config, complex_class, defined)
        classified? ? get_class_ancestors(config, complex_class, defined) : nil
      end

      def find_param_structure
        map.each_with_object({}) do|item, memo|
          memo[item.name] = item.type
          memo
        end
      end

      def remove_type_inheritable_elements(keys)
        self.map = map.delete_if { |element| keys.include?(element.name) }
      end

      def fix_descendant_wash_out_type(config, complex_class)
        param_class = begin
          complex_class.is_a?(Class) ? complex_class : complex_class.constantize
        rescue
          nil
        end
        return unless param_class.present? && param_class.ancestors.include?(WashOut::Type) && map[0].present?
        descendant = WashOut::Param.parse_builder_def(config, param_class.wash_out_param_map)[0]
        self.name = descendant.name
        self.map = descendant.map
      end

      def same_structure_as_ancestor?(ancestor)
        param_structure = find_param_structure
        ancestor_structure = ancestor.find_param_structure
        if param_structure.keys == ancestor_structure.keys
          return true
        else
          remove_type_inheritable_elements(ancestor_structure.keys)
          return false
        end
      end

      def get_ancestors(class_name)
        param_class = begin
          class_name.is_a?(Class) ? class_name : class_name.constantize
        rescue
          nil
        end
        if param_class.nil?
          return nil
        else
          get_complex_type_ancestors(param_class, ['ActiveRecord::Base', 'Object', 'BasicObject', 'WashOut::Type'])
        end
      end

      def complex_type_descendants(config, defined)
        if struct?
          c_names = []
          map.each { |obj| c_names.concat(obj.get_nested_complex_types(config, defined)) }
          defined.concat(c_names)
        end
        defined
      end

      def get_nested_complex_types(config, defined)
        defined = [] if defined.blank?
        complex_class = find_complex_class_name(defined)
        fix_descendant_wash_out_type(config, complex_class)
        unless complex_class.nil?
          defined << complex_type_hash(complex_class, self, complex_type_ancestors(config, complex_class, defined))
        end
        defined = complex_type_descendants(config, defined)
        defined.sort_by { |hash| hash[:class].to_s.downcase }.uniq unless defined.blank?
      end

      def ancestor_structure(ancestors)
        { ancestors[0].to_s.downcase => ancestors[0].wash_out_param_map }
      end

      def complex_type_hash(class_name, object, ancestors)
        {
          class: class_name,
          obj: object,
          ancestors: ancestors
        }
      end

      def get_class_ancestors(config, class_name, defined)
        ancestors = get_ancestors(class_name)
        return if ancestors.blank?
        ancestor_object = WashOut::Param.parse_def(config, ancestor_structure(ancestors))[0]
        bool_the_same = same_structure_as_ancestor?(ancestor_object)
        unless bool_the_same
          top_ancestors = get_class_ancestors(config, ancestors[0], defined)
          defined << complex_type_hash(ancestors[0], ancestor_object, top_ancestors)
        end
        ancestors unless bool_the_same
      end
    end
  end
end
