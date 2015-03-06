module WashoutBuilderComplexTypeHelper
  # this method is for printing the attributes of a complex type
  # if the attributes are primitives this will show the attributes with  blue color
  # otherwise will call another method for printing the complex attribute
  def create_element_type_html(pre, element)
    element.type = 'string' if element.type == 'text'
    element.type = 'integer' if element.type == 'int'
    if WashoutBuilder::Type::BASIC_TYPES.include?(element.type)
      pre << "<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"
    else
      create_complex_element_type_html(pre, element)
    end
  end

  # checks if a complex attribute of a complex type is a array or not
  # and retrieves the complex class name of the attribute and prints it
  def create_complex_element_type_html(pre, element)
    complex_class = element.get_complex_class_name
    return unless complex_class.nil?
    complex_class_content = element.multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class_content}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
  end
end
