module WashoutBuilder
  # module that extends the base WashoutParam to allow parsing of definitions for building documentation
  module Param
    extend ActiveSupport::Concern

    # Method that receives the arguments for a soap action (input or output) and tries to parse the definition (@see WashOutParam#parse_def)
    #
    # the following lines was removed from original method because when generating the documentation
    #  the "source_class" attrtibute of the object was not the name of the class of the complex tyoe
    # but instead was the name given in the hash
    #
    # if definition.is_a?(Class) && definition.ancestors.include?(WashOut::Type)
    #        definition = definition.wash_out_param_map
    #    end
    #
    # @example Given the class ProjectType as a "definition" argument, the complex type name should be  ProjectType and not "project"
    #  class ProjectType < WashOut::Type
    #  map :project => {
    # :name                                    => :string,
    #  :description                           => :string,
    #  :users                                    => [{:mail => :string }],
    #  }
    # end
    #
    #
    # @see WashoutBuilder::SOAP#soap_action
    # @see WashOutParam#initialize
    #
    # @param [WasOut::SoapConfig] soap_config Holds the soap configuration for the entire web service
    # @param [Object] definition  Any type of object ( this is passed from the soap action)
    #
    # @return [Type] description of returned object
    def parse_builder_def(soap_config, definition)
      raise '[] should not be used in your params. Use nil if you want to mark empty set.' if definition == []
      return [] if definition.blank?

      definition = { value: definition } unless definition.is_a?(Hash) # for arrays and symbols

      definition.map do |name, opt|
        if opt.is_a? self
          opt
        elsif opt.is_a? Array
          new(soap_config, name, opt[0], true)
        else
          new(soap_config, name, opt)
        end
      end
    end
  end
end
