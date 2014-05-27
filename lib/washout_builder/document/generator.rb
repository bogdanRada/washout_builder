require_relative "./exception_model"
module WashoutBuilder
  module Document
    class Generator
       
      @attrs = [:soap_actions, :config, :controller_name]
      
      attr_reader *@attrs
      attr_accessor  *@attrs
      
      def initialize(controller)
          controller_class_name = controller_class(controller)
          self.config =controller_class_name.soap_config
          self.soap_actions = controller_class_name.soap_actions
          self.controller_name = controller
      end
     
      def namespace
        config.respond_to?(:namespace) ? config.namespace : nil
      end
      
      def controller_class(controller)
        "#{controller}_controller".camelize.constantize
      end
  
      def endpoint 
        namespace.blank? ? nil : namespace.gsub("/wsdl", "/action")
      end
      
      def service 
        controller_name.blank? ? nil : controller_name.camelize
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
     
     
      def filter_exceptions_raised
        exceptions_raised.select { |x|  WashoutBuilder::Type.valid_fault_class?(x)  }  unless actions_with_exceptions.blank?
      end
      
      def get_complex_fault_types(fault_types)
        defined  = filter_exceptions_raised
        if defined.blank?
          defined = [WashoutBuilder::Type.get_fault_classes.first]
        else
          defined  << WashoutBuilder::Type.get_fault_classes.first
        end
        defined.each{ |exception_class|  exception_class.get_fault_class_ancestors( fault_types, true)}  unless   defined.blank?
        fault_types 
      end
      
      def fault_types
        fault_types = get_complex_fault_types([])
        complex_types = extract_nested_complex_types_from_exceptions(fault_types)
        complex_types.delete_if{ |hash|  fault_types << hash   if  WashoutBuilder::Type.valid_fault_class?(hash[:fault])  } unless complex_types.blank?
        fault_types = sort_complex_types(fault_types, "fault")
        complex_types = sort_complex_types(complex_types, "fault")
        [fault_types, complex_types]
      end
      
      def extract_nested_complex_types_from_exceptions(fault_types)
        complex_types = []
        fault_types.each do |hash| 
          hash[:structure].each do |attribute, attr_details|
            complex_class = hash[:fault].get_virtus_member_type_primitive(attr_details)
            WashoutBuilder::Document::ExceptionModel.extract_nested_complex_types(complex_class, complex_types)
          end
        end
        complex_types
      end
      
       
       
    
      
    end
  end
end