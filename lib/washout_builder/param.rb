module WashoutBuilder
  class Param < WashOut::Param
   
    attr_accessor :source_class_name
    
    def initialize(soap_config, name, type, class_name, multiplied = false)
      @source_class_name = class_name
       super(soap_config, name, type, multiplied )
    end
    
    def self.parse_def(soap_config, definition)
      raise RuntimeError, "[] should not be used in your params. Use nil if you want to mark empty set." if definition == []
      return [] if definition == nil

      definition_class_name = nil
      if definition.is_a?(Class) && definition.ancestors.include?(WashOut::Type)
        definition_class_name = definition.to_s.demodulize.classify
        definition = definition.wash_out_param_map
      end

      if [Array, Symbol].include?(definition.class)
        definition = { :value => definition }
      end

      if definition.is_a? Hash
        definition.map do |name, opt|
          if opt.is_a? WashoutBuilder::Param
             opt
          elsif opt.is_a? Array
           WashoutBuilder::Param.new(soap_config, name, opt[0],definition_class_name, true)
          else
            WashoutBuilder::Param.new(soap_config, name, opt, definition_class_name)
          end
        end
      else
        raise RuntimeError, "Wrong definition: #{definition.inspect}"
      end
    end
    
    def basic_type
      return source_class_name unless source_class_name.nil?
      super
    end
  
    def is_complex?
      !source_class_name.nil? || (struct? && classified? ) || struct?
    end
    
    
  end
end
