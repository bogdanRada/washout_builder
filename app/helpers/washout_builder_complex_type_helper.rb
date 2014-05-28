module WashoutBuilderComplexTypeHelper
  
  def create_complex_type_element_html(xml, element)
    element.type = "string" if element.type == "text"
    element.type = "integer" if element.type == "int"
    xml.li { |pre|
      if WashoutBuilder::Type::BASIC_TYPES.include?(element.type)
        pre << "<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"
      else
        create_element_type_html(pre, element)
      end
    }
  end
  
  def create_element_type_html(pre, element)
    complex_class = element.get_complex_class_name
    unless  complex_class.nil?
      complex_class_content =  element.multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
      pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class_content}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
    end
  end

end


  