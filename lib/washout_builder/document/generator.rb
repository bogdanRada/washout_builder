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
        config.description
      end
      
      def operations
        soap_actions.map { |operation, formats| operation }
      end
      
      
      def input_types
        types = []
        soap_actions.each do |operation, formats|
          (formats[:in]).each do |p|
            types << p
          end
        end
        types
      end
      
      def output_types
        types = []
        soap_actions.each do |operation, formats|
          (formats[:out]).each do |p|
            types << p
          end
        end
        types
      end
      
      def get_soap_action_names
        operations.map(&:to_s).sort_by { |name| name.downcase }.uniq unless soap_actions.blank?
      end
      
      
      def complex_types
        defined = []
        (input_types + output_types).each do |p|
          defined.concat(get_nested_complex_types(p, defined))
        end
        defined.sort_by { |hash| hash[:class].to_s.downcase }.uniq unless defined.blank?
      end
      

      def get_nested_complex_types(param, defined)
        defined = [] if defined.blank?
        complex_class = param.get_complex_class_name( defined)
        param.fix_descendant_wash_out_type( config, complex_class)
        defined << {:class =>complex_class, :obj => param, :ancestors => param.classified?  ?  get_class_ancestors(param, complex_class, defined) : nil } unless complex_class.nil?
        if param.struct?
          c_names = []
          param.map.each { |obj|   c_names.concat(get_nested_complex_types(obj, defined))  }        
          defined.concat(c_names)
        end
        defined.sort_by { |hash| hash[:class].to_s.downcase }.uniq unless defined.blank?
      end

        
     
      
      def get_class_ancestors(param, class_name, defined)
        bool_the_same = false
        ancestors   = param.get_ancestors(class_name)
        unless ancestors.blank?
          ancestor_structure =   { ancestors[0].to_s.downcase => ancestors[0].wash_out_param_map }
          ancestor_object =  WashOut::Param.parse_def(config,ancestor_structure)[0]
          bool_the_same = param.same_structure_as_ancestor?( ancestor_object)
          unless bool_the_same
            top_ancestors = get_class_ancestors(ancestor_object,ancestors[0], defined)
            defined << {:class =>ancestors[0], :obj =>ancestor_object ,  :ancestors => top_ancestors   }
          end
          ancestors unless  bool_the_same
        end
      end
      
       
      def fault_types
        defined = soap_actions.select{|operation, formats| !formats[:raises].blank? }
        defined = defined.collect {|operation, formats|  formats[:raises].is_a?(Array)  ? formats[:raises] : [formats[:raises]] }.flatten.select { |x| x.is_a?(Class) && x.ancestors.include?(WashOut::SOAPError) }  unless defined.blank?
        fault_types = []
        if defined.blank?
          defined = [WashOut::SOAPError] 
        else
          defined  << WashOut::SOAPError
        end
        defined.each{ |item|  item.get_fault_class_ancestors( fault_types, true)}  unless   defined.blank?
        complex_types = extract_nested_complex_types_from_exceptions(fault_types)
        complex_types.delete_if{ |hash|  fault_types << hash if  hash[:fault].ancestors.include?(WashOut::SOAPError) } unless complex_types.blank?
        fault_types = fault_types.sort_by { |hash| hash[:fault].to_s.downcase }.uniq unless fault_types.blank?  
        complex_types = complex_types.sort_by { |hash| hash[:fault].to_s.downcase }.uniq unless complex_types.blank?
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