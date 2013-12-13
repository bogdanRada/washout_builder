xml.instruct!
xml.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"

xml.html( "xmlns" => "http://www.w3.org/1999/xhtml" ) {

  xml.head {

    xml.title "#{@document.service} interface description"

    xml.style( "type"=>"text/css" ,"media" => "all" ) { xml.text! "
    body{font-family:Calibri,Arial;background-color:#fefefe;}
    .pre{font-family:Courier;}
    .normal{font-family:Calibri,Arial;}
    .bold{font-weight:bold;}
    h1,h2,h3{font-family:Verdana,Times;}
    h1{border-bottom:1px solid gray;}
    h2{border-bottom:1px solid silver;}
    h3{border-bottom:1px dashed silver;}
    a{text-decoration:none;}
    a:hover{text-decoration:underline;}
    .blue{color:#3400FF;}
    .lightBlue{color:#5491AF;}
      "
    }

    xml.style( "type"=>"text/css", "media" => "print" ) { xml.text! "
    .noprint{display:none;}
      "
    }
  }

  xml.body {

    xml.h1 "#{ @document.service} Soap WebService interface description"

    xml.p{ |y| y << "Endpoint URI:";
      xml.span( "class" => "pre") { |y| y << "#{@document.endpoint}"};
    }

    xml.p{ |y| y << "WSDL URI:";
      xml.span( "class" => "pre") {
        xml.a( "href" => "#{@document.namespace}") { |y| y << "#{@document.namespace}" }
      };}

    unless @document.service_description.blank?
      xml.h1 "#{@document.service}"
      xml.p "#{@document.service_description}"
    end

    xml.div("class" => "noprint") {

      xml.h2 "Index "
      @complex_types =  @document.complex_types
      @fault_types, @fault_complex_types = get_fault_types(@map)
      unless @complex_types.blank?
        xml.p  "Complex Types: "
      
        xml.ul do
          @complex_types.each do |hash|
            xml.li { |y| y << "<a href='##{hash[:class]}'><span class='pre'>#{hash[:class]}</span></a>" }
          end
          unless @fault_complex_types.blank?
            @fault_complex_types.each do |hash| 
              xml.li { |y| y << "<a href='##{hash[:fault].to_s}'><span class='pre'>#{hash[:fault].to_s}</span></a>" } 
            end
          end
        end
      
      end
      
      unless @fault_types.blank?
        xml.p  "Fault Types: "

        xml.ul do
          @fault_types.each do |hash|
            xml.li { |y| y << "<a href='##{hash[:fault].to_s}'><span class='pre'>#{hash[:fault].to_s}</span></a>" }
          end
        end
      end

      @methods = get_soap_action_names(@map)
      unless @methods.blank?
        xml.p  "Public Methods:"

        xml.ul do
          @methods.each do |name|
            xml.li { |y| y << "<a href='##{name}'><span class='pre'>#{name}</span></a>" }
          end
        end
      end

    }

    unless @complex_types.blank?
      xml.h2 "Complex types:"
      create_html_complex_types(xml, @complex_types)
    end
    unless @fault_complex_types.blank?
      create_html_fault_types_details(xml, @fault_complex_types)
    end
    unless @fault_types.blank?
      xml.h2 "Fault types:"
      create_html_fault_types_details(xml, @fault_types)
    end
    unless @methods.blank?
      xml.h2 "Public methods:"
      create_html_public_methods(xml, @map)
    end
    
    if @complex_types.blank? && @fault_types.blank? &&  @methods.blank?
      xml.p "There are no soap actions defined yet for this service. Please add some actions and try again!"
    end
    
    
  }

}