module WashoutBuilder
  module Document
    # module that is used for both complex types and exception class to find their ancestors and filter out some of the ancestors
    module SharedComplexType
      # Method that is used to fetch the ancestors of a class and fiter the ancestors that are present in the second argument
      #
      # @param [Class] class_name The class that is used to fetch the ancestors for
      # @param [Array<Class>] array The array of classes that should be fitered from the ancestors if they are present
      # @return [Array<Class>] The classes from which the class given as first argument inherits from but filtering the classes passed as second argument
      def get_complex_type_ancestors(class_name, array)
        (class_name.ancestors - class_name.included_modules).delete_if do |x|
          x.to_s.downcase == class_name.to_s.downcase ||
            array.include?(x.to_s) ||
            (x.respond_to?(:abstract_class) && x.abstract_class)
        end
      end
    end
  end
end
