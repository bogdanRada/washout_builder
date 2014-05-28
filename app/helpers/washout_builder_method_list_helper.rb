module WashoutBuilderMethodListHelper
  
  def create_element_exceptions_list_html(p)
    xml.li("class" => "pre"){ |y| y<< "<a href='##{p.to_s}'><span class='lightBlue'> #{p.to_s}</span></a>" }
  end
  
  def create_parameters_element_list_html(xml, param)
    xml.li("class" => "pre") { |pre|
      if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
        pre << "<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
      else
        create_element_type_html(pre, param)
      end
    }
  end
  
  def create_return_complex_type_list_html(xml, complex_class, builder_out)
    return_content =  builder_out[0].multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    xml.span("class" => "pre") { xml.a("href" => "##{complex_class}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"#{return_content}" } } }
  end

  
  def create_return_type_list_html(xml, output)
    unless output.nil?
      complex_class = output[0].get_complex_class_name  
      if WashoutBuilder::Type::BASIC_TYPES.include?(output[0].type)
        xml.span("class" => "pre") { |xml| xml.span("class" => "blue") { |sp| sp << "#{output[0].type}" } }
      else
        create_return_complex_type_html(xml, complex_class, output) unless complex_class.nil?
      end
    else
      xml.span("class" => "pre") { |sp| sp << "void" }
    end
    
  
  end  
    
end