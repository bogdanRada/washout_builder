module WashoutBuilderMethodListHelper
  
 
  
  def create_return_complex_type_list_html(xml, complex_class, builder_out)
    return_content =  builder_out[0].multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    xml.span("class" => "pre") { xml.a("href" => "##{complex_class}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"#{return_content}" } } }
  end

  
  def create_return_type_list_html(xml, output)
    if output.nil?
      xml.span("class" => "pre") { |sp| sp << "void" }
    else
      complex_class = output[0].get_complex_class_name  
      if WashoutBuilder::Type::BASIC_TYPES.include?(output[0].type)
        xml.span("class" => "pre") { |xml| xml.span("class" => "blue") { |sp| sp << "#{output[0].type}" } }
      else
        create_return_complex_type_html(xml, complex_class, output) unless complex_class.nil?
      end
    end
  end  
    
end
