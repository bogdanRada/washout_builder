module WashoutBuilderFaultTypeHelper
  
  # checks if a complex attribute of a complex type SoapFault is array or not
  # if the attribute is an array will print also the type of the elements contained in the array
  # otherwise will show the complex class of the attribute
  def create_fault_model_complex_element_type(pre, attr_primitive, attribute, array)
    attribute_primitive = array == true ? "Array of #{attr_primitive}" : "#{attr_primitive}"
    pre << "<a href='##{attr_primitive}'><span class='lightBlue'> #{attribute_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
  end
  
  # if the attribute is an array  this method is used to identify the type of the elements inside the array
  def member_type_is_basic?(attr_details)
    WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase) ? attr_details[:member_type].to_s.downcase : attr_details[:member_type]
  end
  # checks is the attribute has a primitive value or a complex value
  def primitive_type_is_basic?(attr_details)
    WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase) 
  end

  # if the attribute value is of type nil the documentation will show string 
  # otherwise the primitive value
  def get_primitive_type_string(attr_details)
    attr_details[:primitive].to_s.downcase == "nilclass" ? "string" : attr_details[:primitive].to_s.downcase
  end  
  
  # if the attribute is of type array the method identifies the type of the elements inside the array
  def get_member_type_string(attr_details)
    attr_details[:primitive].to_s.downcase == "array" ? member_type_is_basic?(attr_details) :  attr_details[:primitive]
  end
  
  # this method is used to print all attributes of a SoapFault element 
  # if the attribute value is a primitve value it will be shown in blue and will also show the type of the primitive
  # if is a complex type will use another method for finding out the complex class 
  def create_html_fault_model_element_type(pre, attribute, attr_details)
    if primitive_type_is_basic?(attr_details) || attr_details[:primitive] == "nilclass" 
      pre << "<span class='blue'>#{get_primitive_type_string(attr_details)}</span>&nbsp;<span class='bold'>#{attribute}</span>"
    else
      create_fault_model_complex_element_type(pre, get_member_type_string(attr_details), attribute, true )
    end
  end
end
