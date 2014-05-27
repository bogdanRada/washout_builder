module WashoutBuilder
  module TrackExceptionAttributes
      
    def attr_accessor(*vars)
      @@attributes ||= []
      @@attributes.concat vars
      super(*vars)
    end
  
    def attr_accessible(*vars)
      @@attributes ||= []
      @@attributes.concat vars
      super(*vars)
    end
  
    def attr_writer(*vars)
      @@attributes ||= []
      @@attributes.concat vars
      super(*vars)
    end
  
    def attr_reader(*vars)
      @@attributes ||= []
      @@attributes.concat vars
      super(*vars)
    end
   
    
    def attributes
      @@attributes
    end
    
  end
end