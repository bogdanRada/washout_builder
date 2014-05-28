module WashoutBuilderMethodReturnTypeHelper

  def create_html_public_method_return_type(xml,pre, output)
    if !output.nil?
      complex_class = output[0].get_complex_class_name  
      if WashoutBuilder::Type::BASIC_TYPES.include?(output[0].type)
        xml.span("class" => "blue") { |y| y<<  "#{output[0].type}" }
      else
        complex_return_type =  output[0].multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
        pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_return_type}</span></a>" unless complex_class.nil?
      end
    else
      pre << "void"
    end
  end
  
  


end
