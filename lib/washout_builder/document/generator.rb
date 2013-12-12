module WashoutBuilder
  module Document
    class Generator
       
      @attrs = [:map, :config, :service_class]
      
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
      
      
      
    end
  end
end