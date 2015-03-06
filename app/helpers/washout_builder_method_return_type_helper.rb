module WashoutBuilderMethodReturnTypeHelper
  def create_html_public_method_return_type(xml, pre, output)
    if !output.nil?
      complex_class = output[0].get_complex_class_name
      if WashoutBuilder::Type::BASIC_TYPES.include?(output[0].type)
        xml.span('class' => 'blue') { |y| y << "#{output[0].type}" }
      else
        html_public_method_complex_type(pre, output, complex_class)
      end
    else
      pre << 'void'
    end
  end

  def html_public_method_complex_type(pre, output, complex_class)
    return if complex_class.nil?
    if output[0].multiplied == false
      complex_return_type = "#{complex_class}"
    else
      complex_return_type = "Array of #{complex_class}"
    end
    pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_return_type}</span></a>"
  end
end
