module WashoutBuilder
  module Document
    class Generator
       
      @attrs = [:soap_actions, :config, :service_class]
      
      attr_reader *@attrs
      attr_accessor  *@attrs
      
      def initialize(attrs = {})
        self.config = attrs[:config]
        self.service_class = attrs[:service_class]
        self.soap_actions = attrs[:soap_actions]
      end
     
      def namespace
        config.namespace
      end
      
      
      def endpoint 
        namespace.gsub("/wsdl", "/action")
      end
      
      def service 
        service_class.name.underscore.gsub("_controller", "").camelize
      end
      
      def service_description
        config.respond_to?(:description) ? config.description : nil
      end
      
      def operations
        soap_actions.map { |operation, formats| operation }
      end
      
      def sort_complex_types(types, type)
         types.sort_by { |hash| hash[type.to_sym].to_s.downcase }.uniq {|hash| hash[type.to_sym] } unless types.blank?
      end
      
      
      def argument_types(type)
        format_type = (type == "input") ? "builder_in" : "builder_out"
        types = []
        unless soap_actions.blank?
          soap_actions.each do |operation, formats|
            (formats[format_type.to_sym]).each do |p|
              types << p
            end
          end
        end
        types
      end
      
      def input_types
        argument_types("input")
      end
      
      def output_types
        argument_types("output")
      end
      
      def get_soap_action_names
        operations.map(&:to_s).sort_by { |name| name.downcase }.uniq unless soap_actions.blank?
      end
      
      
      def complex_types
        defined = []
        (input_types + output_types).each do |p|
          defined.concat(p.get_nested_complex_types(config,  defined))
        end
        defined =  sort_complex_types(defined, "class")
      end
            
       
      def actions_with_exceptions
         soap_actions.select{|operation, formats| !formats[:raises].blank? }
      end
      
      def exceptions_raised
         actions_with_exceptions.collect {|operation, formats|  formats[:raises].is_a?(Array)  ? formats[:raises] : [formats[:raises]] }.flatten
      end
      
      def fault_classes
          WashoutBuilder::Type.get_fault_classes
      end
      
      def has_ancestor_fault?(fault_class)
        fault_class.ancestors.detect{ |fault|  fault_classes.include?(fault)  }.present?
      end
      
      def valid_fault_class?(fault)
         fault.is_a?(Class) &&   ( has_ancestor_fault?(fault) ||  fault_classes.include?(fault)) 
      end
      
      def filter_exceptions_raised
        exceptions_raised.select { |x|  valid_fault_class?(x)  }  unless actions_with_exceptions.blank?
      end
      
      def get_complex_fault_types(fault_types)
        defined  = filter_exceptions_raised
        if defined.blank?
          defined = [fault_classes.first]
        else
          defined  << fault_classes.first
        end
        defined.each{ |exception_class|  exception_class.get_fault_class_ancestors( fault_types, true)}  unless   defined.blank?
        fault_types 
      end
      
      def fault_types
        fault_types = get_complex_fault_types([])
        complex_types = extract_nested_complex_types_from_exceptions(fault_types)
        complex_types.delete_if{ |hash|  fault_types << hash   if  valid_fault_class?(hash[:fault])  } unless complex_types.blank?
        fault_types = sort_complex_types(fault_types, "fault")
        complex_types = sort_complex_types(complex_types, "fault")
        [fault_types, complex_types]
      end
      
      def extract_nested_complex_types_from_exceptions(fault_types)
        complex_types = []
        fault_types.each do |hash| 
          hash[:structure].each do |attribute, attr_details|
            complex_class = hash[:fault].get_virtus_member_type_primitive(attr_details)
            unless complex_class.nil?
              param_class = complex_class.is_a?(Class) ? complex_class : complex_class.constantize rescue nil
              if !param_class.nil? && param_class.ancestors.include?(Virtus::Model::Core)
                param_class.send :extend, WashoutBuilder::Document::VirtusModel
                param_class.get_fault_class_ancestors( complex_types)
              elsif !param_class.nil? && !param_class.ancestors.include?(Virtus::Model::Core)
                raise RuntimeError, "Non-existent use of `#{param_class}` type name or this class does not use Virtus.model. Consider using classified types that include Virtus.mode for exception atribute types."
              end 
            end
          end 
        end
        complex_types
      end
       
       
       
    
      
    end
  end
end