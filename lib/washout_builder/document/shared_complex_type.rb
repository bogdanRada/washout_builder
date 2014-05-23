module WashoutBuilder
  module Document
    module SharedComplexType
      
      
        def get_complex_type_ancestors(class_name, array)
        (class_name.ancestors - class_name.included_modules).delete_if{ |x| x.to_s.downcase == class_name.to_s.downcase  ||  array.include?(x.to_s)  }
      end
      
    end
  end
end