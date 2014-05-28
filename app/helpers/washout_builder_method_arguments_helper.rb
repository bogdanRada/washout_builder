module WashoutBuilderMethodArgumentsHelper
 
  def create_method_argument_element( pre, param, mlen)
    spacer = "&nbsp;&nbsp;&nbsp;&nbsp;"
    complex_class = param.get_complex_class_name  
    use_spacer =  mlen > 1 ? true : false
    if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
      pre << "#{use_spacer ? spacer: ''}<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
    else
      unless complex_class.nil?
        argument_content = param.multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
        pre << "#{use_spacer ? spacer: ''}<a href='##{complex_class}'><span class='lightBlue'>#{argument_content}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
      end
    end
  end
  
  def create_argument_element_spacer(xml, j, mlen )
    if j< (mlen-1)
      xml.span ", "
    end
    if mlen > 1
      xml.br
    end
    if (j+1) == mlen
      xml.span("class" => "bold") {|y|  y << ")" }
    end
  end
  
  
  
  def create_html_public_method_arguments(xml, pre, input)
    mlen = input.size
    xml.br if mlen > 1
    if mlen > 0
      input.each_with_index do |element, index|
        create_method_argument_element( pre, element, mlen)
        create_argument_element_spacer(xml, index, mlen )
      end
    end
  end
end