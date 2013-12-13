module WashoutBuilder
  module Document
    module ComplexType
      extend ActiveSupport::Concern
      
      
      def get_complex_class_name(defined = [])
        complex_class =  struct? ? basic_type : nil
        complex_class =  complex_class.include?(".") ? complex_class.gsub(".","/").camelize : complex_class.classify    unless complex_class.nil?
     
        unless complex_class.nil? || defined.blank?
     
          complex_obj_found = defined.detect {|hash|   hash[:class] == complex_class}
    
          if !complex_obj_found.nil? && struct?  &&  !classified?
            raise RuntimeError, "Duplicate use of `#{p.basic_type}` type name. Consider using classified types."
          end
        end
   
        return complex_class
      end
      
      def get_param_structure
        map.inject({}) {|h,element|  h[element.name] = element.type;h }
      end
  
  
      def remove_type_inheritable_elements( keys)
        map.delete_if{|element|  keys.include?(element.name) }
      end
  
      
      
      def fix_descendant_wash_out_type(config, complex_class)
        param_class = complex_class.is_a?(Class) ? complex_class : complex_class.constantize rescue nil
        if !param_class.nil? && param_class.ancestors.include?(WashOut::Type) && !map[0].nil? 
          descendant = WashOut::Param.parse_def(config, param_class.wash_out_param_map)[0]
          self.name =  descendant.name 
          self.map = descendant.map
        end
      end
      
     
      def  same_structure_as_ancestor?(ancestor)
        param_structure = get_param_structure
        ancestor_structure = ancestor.get_param_structure
        if  param_structure.keys == ancestor_structure.keys
          return true
        else 
          remove_type_inheritable_elements( ancestor_structure.keys)
          return false
        end
      end
  
      def parse_custom_type_class(param_class)
       if  param_class.is_a?(Class)
        WashOut::Param.parse_def(config, param_class.wash_out_param_map)[0]
       else
       end
      end
      
      def get_ancestors(class_name)
        param_class = class_name.is_a?(Class) ? class_name : class_name.constantize rescue nil
        if  param_class.nil?
          return nil
        else
           (param_class.ancestors - param_class.included_modules).delete_if{ |x| x.to_s.downcase == class_name.to_s.downcase  ||  x.to_s == "ActiveRecord::Base" ||  x.to_s == "Object" || x.to_s =="BasicObject" || x.to_s == "WashOut::Type" }
        end
      end
  
      
    
  
     
  
  
    end
  end
end