module WashoutBuilder
  module Param 
      
    attr_accessor :source_class_name
    attr_accessor :timestamp
    
     def initialize(soap_config, name, type, class_name, multiplied = false)
      type ||= {}
      @soap_config = soap_config
      @name = name.to_s
      @raw_name = name.to_s
      @map = {}
      @multiplied = multiplied
      @source_class_name = class_name

      if soap_config.camelize_wsdl.to_s == 'lower'
        @name = @name.camelize(:lower)
      elsif soap_config.camelize_wsdl
        @name = @name.camelize
      end

      if type.is_a?(Symbol)
        @type = type.to_s
      elsif type.is_a?(Class)
        @type = 'struct'
        @map = self.class.parse_def(soap_config, type.wash_out_param_map)
        @source_class = type
      else
        @type = 'struct'
        @map = self.class.parse_def(soap_config, type)
      end
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
          if opt.is_a? WashOut::Param
             opt
          elsif opt.is_a? Array
            WashOut::Param.new(soap_config, name, opt[0],definition_class_name, true)
          else
            WashOut::Param.new(soap_config, name, opt, definition_class_name)
          end
        end
      else
        raise RuntimeError, "Wrong definition: #{definition.inspect}"
      end
    end
    
    
  end
end