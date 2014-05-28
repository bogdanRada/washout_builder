module WashoutBuilderFaultTypeHelper
  
  def create_fault_model_complex_element_type(pre, attr_primitive, attribute, array)
    attribute_primitive = array == true ? "Array of #{attr_primitive}" : "#{attr_primitive}"
    pre << "<a href='##{attr_primitive}'><span class='lightBlue'> #{attribute_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
  end
  
  
  def member_type_is_basic?(attr_details)
    WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase) ? attr_details[:member_type].to_s.downcase : attr_details[:member_type]
  end
  
  def primitive_type_is_basic?(attr_details)
   WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase) 
  end

  def get_primitive_type_string(attr_details)
    attr_details[:primitive].to_s.downcase == "nilclass" ? "string" : attr_details[:primitive].to_s.downcase
  end  
  
  def get_member_type_string(attr_details)
    attr_details[:primitive].to_s.downcase == "array" ? member_type_is_basic?(attr_details) :  attr_details[:primitive]
  end
  
  def create_html_fault_model_element_type(pre, attribute, attr_details)
    if primitive_type_is_basic?(attr_details) || attr_details[:primitive] == "nilclass" 
      pre << "<span class='blue'>#{get_primitive_type_string(attr_details)}</span>&nbsp;<span class='bold'>#{attribute}</span>"
    else
      create_fault_model_complex_element_type(pre, get_member_type_string(attr_details), attribute, true )
    end
  end
end