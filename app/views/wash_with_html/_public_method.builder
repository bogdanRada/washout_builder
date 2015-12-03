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
        xml.li("class" => "pre") { |pre|
          create_element_type_html(pre, element, args_description.nil? ? nil : args_description[element.name.to_sym])
        }
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
       xml.li("class" => "pre"){ |y| y<< "<a href='##{p.to_s}'><span class='lightBlue'> #{p.to_s}</span></a>" }
      end
    }
end
