module WashoutBuilder
  module Document
    module VirtusModel
      extend ActiveSupport::Concern
      
      def get_fault_class_ancestors( defined, debug = false)
        bool_the_same = false
        ancestors  = fault_ancestors
        if  ancestors.blank?
          defined << fault_ancestor_hash(get_virtus_model_structure, []) 
        else
          defined << fault_ancestor_hash(fault_without_inheritable_elements(ancestors), ancestors)
          ancestors[0].get_fault_class_ancestors( defined)
        end
        ancestors unless  bool_the_same
      end
      
           
      def fault_without_inheritable_elements(ancestors)
        remove_fault_type_inheritable_elements(  ancestors[0].get_virtus_model_structure.keys)
      end
      
      def fault_ancestors
        (self.ancestors - self.included_modules).delete_if{ |x| x.to_s.downcase == self.to_s.downcase  ||  x.to_s == "ActiveRecord::Base" ||  x.to_s == "Object" || x.to_s =="BasicObject"   || x.to_s == "Exception" }
      end
      
      def fault_ancestor_hash( structure, ancestors)
        {:fault => self,:structure =>structure  ,:ancestors => ancestors   }
      end
      
      def remove_fault_type_inheritable_elements( keys)
        get_virtus_model_structure.delete_if{|key,value|  keys.include?(key) }
      end
       
      
      def attr_details_array?(attr_details)
        attr_details[:primitive].to_s.downcase == "array" 
      end
      
      def attr_details_basic_type?(attr_details, field)
        WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[field.to_sym].to_s.downcase)
      end
      
      def get_virtus_member_type_primitive(attr_details)
        complex_class = nil
        if attr_details_array?(attr_details) && !attr_details_basic_type?(attr_details, "member_type")
          complex_class = attr_details[:member_type]
        elsif !attr_details_array?(attr_details) && !attr_details_basic_type?(attr_details, "primitive")
          complex_class = attr_details[:primitive]
        end
        complex_class
      end
 
       
      def get_virtus_model_structure
        attribute_set.inject({}) {|h, elem|  h["#{elem.name}"]= { :primitive => "#{elem.primitive}", :member_type => elem.options[:member_type].nil? ? nil: elem.options[:member_type].primitive }; h }
      end
      
      
    end
  end
end
