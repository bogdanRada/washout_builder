module WashoutBuilderFaultTypeHelper
  
  def create_fault_model_complex_element_type(pre, attr_primitive, attribute, array)
    attribute_primitive = array == true ? "Array of #{attr_primitive}" : "#{attr_primitive}"
    pre << "<a href='##{attr_primitive}'><span class='lightBlue'> #{attribute_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
  end
  
  
  def create_html_fault_model_element_type(xml, attribute, attr_details)
    xml.li { |pre|
      if WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase) || attr_details[:primitive] == "nilclass" 
        pre << "<span class='blue'>#{attr_details[:primitive].to_s.downcase == "nilclass" ? "string" : attr_details[:primitive].to_s.downcase }</span>&nbsp;<span class='bold'>#{attribute}</span>"
        
      else
        if  attr_details[:primitive].to_s.downcase == "array"
          
          attr_primitive =  WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase) ? attr_details[:member_type].to_s.downcase : attr_details[:member_type]
          create_fault_model_complex_element_type(pre,attr_primitive, attribute, true )
        else
          create_fault_model_complex_element_type(pre,attr_details[:primitive], attribute, false )
        end
      end
    }
  end
end