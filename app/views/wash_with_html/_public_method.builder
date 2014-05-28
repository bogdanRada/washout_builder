xml.h3 "#{operation}"
xml.a("name" => "#{operation}") {}

xml.p("class" => "pre"){ |pre|
  create_html_public_method_return_type(xml,pre, output)
  xml.span("class" => "bold") {|y|  y << "#{operation} (" }
  create_html_public_method_arguments(xml, pre, input)
}
xml.p "#{description}" unless description.blank?


 xml.p "Parameters:"
    xml.ul {
      input.each do |element|
        create_parameters_element_list_html(xml,element)
      end
    }

  xml.p "Return value:"
    xml.ul {
      xml.li {
    
        create_return_type_list_html(xml,output)
      }
    }


operation_exceptions = @document.operation_exceptions(operation)
unless operation_exceptions.blank?
xml.p "Exceptions:"
    xml.ul {
      operation_exceptions.each do |p|
       create_element_exceptions_list_html(p)
      end
    }
end
