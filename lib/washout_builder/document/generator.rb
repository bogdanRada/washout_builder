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
      
      def complex_types
        defined = []
        (input_types + output_types).each do |p|
          defined.concat(get_nested_complex_types(p, defined))
        end
        defined.sort_by { |hash| hash[:class].downcase }.uniq unless defined.blank?
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
        defined.sort_by { |hash| hash[:class].downcase }.uniq unless defined.blank?
      end

        
        def get_ancestor_structure(ancestor)
        { ancestor.to_s.downcase =>  ancestor.columns_hash.inject({}) {|h, (k,v)|  h["#{k}"]="#{v.type}".to_sym; h } }
      end
      
       def get_class_ancestors(param, class_name, defined)
        bool_the_same = false
       ancestors   = param.get_ancestors(class_name)
         unless ancestors.blank?
            ancestor_structure =  get_ancestor_structure(ancestors[0])
            ancestor_object =  WashOut::Param.parse_def(config,ancestor_structure)[0]
            bool_the_same = param.same_structure_as_ancestor?( ancestor_object)
            unless bool_the_same
              top_ancestors = get_class_ancestors(ancestor_object,ancestors[0], defined)
             defined << {:class =>ancestors[0], :obj =>ancestor_object ,  :ancestors => top_ancestors   }
            end
          ancestors unless  bool_the_same
        end
      end
      
      
    end
  end
end