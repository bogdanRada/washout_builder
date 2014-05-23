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
      
      def sort_fault_types(types)
         types.sort_by { |hash| hash[:fault].to_s.downcase }.uniq {|hash| hash[:fault] } unless types.blank?
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
        defined.sort_by { |hash| hash[:class].to_s.downcase }.uniq{|hash| hash[:class] } unless defined.blank?
      end
            
       
      def actions_with_exceptions
         soap_actions.select{|operation, formats| !formats[:raises].blank? }
      end
      
      def exceptions_raised
       actions = actions_with_exceptions
       faults= actions.collect {|operation, formats|  formats[:raises].is_a?(Array)  ? formats[:raises] : [formats[:raises]] }.flatten.select { |x| (x.is_a?(Class) && x.ancestors.detect{ |fault|  WashoutBuilder::Type.get_fault_classes.include?(fault)  }.present?) || (x.is_a?(Class) && WashoutBuilder::Type.get_fault_classes.include?(x)) }  unless actions.blank?
       if faults.blank?
          faults = [WashoutBuilder::Type.get_fault_classes.first]
        else
          faults  << WashoutBuilder::Type.get_fault_classes.first
        end
        faults
      end
      
      
      def fault_types
        defined = exceptions_raised
        fault_types = []
        defined.each{ |exception_class|  exception_class.get_fault_class_ancestors( fault_types, true)}  unless   defined.blank?
        complex_types = extract_nested_complex_types_from_exceptions(fault_types)
        complex_types.delete_if{ |hash|  fault_types << hash if  (hash[:fault].is_a?(Class) && hash[:fault].ancestors.detect{ |fault|  WashoutBuilder::Type.get_fault_classes.include?(fault)  }.present?) || (hash[:fault].is_a?(Class) && WashoutBuilder::Type.get_fault_classes.include?(hash[:fault]))  } unless complex_types.blank?
        fault_types = sort_fault_types(fault_types)
        complex_types = sort_fault_types(complex_types)
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