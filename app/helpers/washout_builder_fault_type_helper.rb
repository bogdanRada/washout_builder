module WashoutBuilderFaultTypeHelper
  # checks if a complex attribute of a complex type SoapFault is array or not
  # if the attribute is an array will print also the type of the elements contained in the array
  # otherwise will show the complex class of the attribute
  #
  # @param [Array] pre Array that contains the content that will be appended to the xml element li
  # @param [Class] attr_primitive  xml li element to which the html will be appended to
  # @param [Boolean] array  boolean that is used to know if ia primitive is a array of elements
  #
  # @return [void]
  #
  # @api public
  def create_fault_model_complex_element_type(pre, attr_primitive, attribute, array)
    attribute_primitive = array == true ? "Array of #{attr_primitive}" : "#{attr_primitive}"
    pre << "<a href='##{attr_primitive}'><span class='lightBlue'> #{attribute_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
  end

  # if the attribute is an array  this method is used to identify the type of the elements inside the array
  #
  # @param [Hash] attr_details hash that contains the member type and determines if the member typs is complex or not
  # @option attr_details [String] :member_type The member type of the element ( basic or complex type)
  # @option attr_details [String]:primitive  the primitive determines if is an array or not
  #
  # @return [string] if the member tyoe is basic will return the type in downcase letter else will return the member type exactly as it is
  #
  # @api public
  def member_type_is_basic?(attr_details)
    WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase) ? attr_details[:member_type].to_s.downcase : attr_details[:member_type]
  end

  # checks is the attribute has a primitive value or a complex value
  #
  # @param [Hash] attr_details hash that contains the member type and determines if the member typs is complex or not
  # @option attr_details [String] :member_type The member type of the element ( basic or complex type)
  # @option attr_details [String]:primitive  the primitive determines if is an array or not
  #
  # @return [boolean]
  #
  # @api public
  def primitive_type_is_basic?(attr_details)
    WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase)
  end

  # if the attribute value is of type nil the documentation will show string
  # otherwise the primitive value
  # @param [Hash] attr_details hash that contains the member type and determines if the member typs is complex or not
  # @option attr_details [String] :member_type The member type of the element ( basic or complex type)
  # @option attr_details [String]:primitive  the primitive determines if is an array or not
  #
  # @return [String] if the primitive is nilclass will return string , otherwise will return the primitive
  #
  # @api public
  def get_primitive_type_string(attr_details)
    attr_details[:primitive].to_s.downcase == 'nilclass' ? 'string' : attr_details[:primitive].to_s.downcase
  end

  # if the attribute is of type array the method identifies the type of the elements inside the array
  #
  #  @see #member_type_is_basic?
  #
  # @param [Hash] attr_details hash that contains the member type and determines if the member typs is complex or not
  # @option attr_details [String] :member_type The member type of the element ( basic or complex type)
  # @option attr_details [String]:primitive  the primitive determines if is an array or not
  #
  # @return [String] if the primitive is array will call another methiod to check the member type otherwise will return the primitive
  #
  # @api public
  def get_member_type_string(attr_details)
    attr_details[:primitive].to_s.downcase == 'array' ? member_type_is_basic?(attr_details) : attr_details[:primitive]
  end

  # this method is used to print all attributes of a SoapFault element
  # if the attribute value is a primitve value it will be shown in blue and will also show the type of the primitive
  # if is a complex type will use another method for finding out the complex class
  #
  # @see #primitive_type_is_basic?
  #  @see #create_fault_model_complex_element_type
  #  @see #get_primitive_type_string
  #
  # @param [Array] pre Array that contains the content that will be appended to the xml element li
  # @param [String] attribute  The name of the attribute that needs to be printed
  #
  # @param [Hash] attr_details hash that contains the member type and determines if the member typs is complex or not
  # @option attr_details [String] :member_type The member type of the element ( basic or complex type)
  # @option attr_details [String]:primitive  the primitive determines if is an array or not
  #
  # @return [String] if the primitive is basic or nil , will return the primitive type and the attribute with blue, otherwise will print the complex type and the attribute
  #
  # @api public
  def create_html_fault_model_element_type(pre, attribute, attr_details)
    if primitive_type_is_basic?(attr_details) || attr_details[:primitive] == 'nilclass'
      pre << "<span class='blue'>#{get_primitive_type_string(attr_details)}</span>&nbsp;<span class='bold'>#{attribute}</span>"
    else
      create_fault_model_complex_element_type(pre, get_member_type_string(attr_details), attribute, true)
    end
  end
end
