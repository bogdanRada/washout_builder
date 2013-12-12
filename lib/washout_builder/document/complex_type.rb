module WashoutBuilder
  module Document
    class ComplexType
      
      @attrs = [:type]
      
      attr_reader *@attrs
      attr_accessor  *@attrs
      
      def initialize(type)
        self.type = type
      end
      
      def self.all
        
      end
      
    end
  end
end