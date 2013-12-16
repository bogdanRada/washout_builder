module WashoutBuilder
  module Document
    module VirtusModel
      extend ActiveSupport::Concern
      
      def get_fault_class_ancestors( defined, debug = false)
        bool_the_same = false
        ancestors  = (self.ancestors - self.included_modules).delete_if{ |x| x.to_s.downcase == self.to_s.downcase  ||  x.to_s == "ActiveRecord::Base" ||  x.to_s == "Object" || x.to_s =="BasicObject"   || x.to_s == "Exception" }
        if  ancestors.blank?
          defined << {:fault => self,:structure =>get_virtus_model_structure  ,:ancestors => []   }
        else
          fault_structure =  remove_fault_type_inheritable_elements(  ancestors[0].get_virtus_model_structure.keys)
          defined << {:fault => self,:structure =>fault_structure  ,:ancestors => ancestors  }
          ancestors[0].get_fault_class_ancestors( defined)
        end
        ancestors unless  bool_the_same
      end
      
      
      def remove_fault_type_inheritable_elements( keys)
        get_virtus_model_structure.delete_if{|key,value|  keys.include?(key) }
      end
       
      
      
      
      def get_virtus_member_type_primitive(attr_details)
        complex_class = nil
        if  attr_details[:primitive].to_s.downcase == "array" &&  !WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase)
          complex_class = attr_details[:member_type]
        elsif attr_details[:primitive].to_s.downcase != "array" &&  !WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase)
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
