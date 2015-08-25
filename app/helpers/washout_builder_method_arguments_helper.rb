# helper that is used to show the arguments of a method with their types in HTML documentation
module WashoutBuilderMethodArgumentsHelper
  # displays the parameter of a method as argument and determines if the parameter is basic type or complex type
  #
  # @see WashoutBuilder::Document::ComplexType#find_complex_class_name
  # @see #create_method_argument_complex_element
  # @see WashoutBuilder::Type::BASIC_TYPES
  #
  # @param [Array] pre Array that contains the content that will be appended to the xml
  # @param [WashOut::Param] param the parameter what needs to be displayed
  # @param [Integer] mlen  Determines if we need a spacer when appending the html or not
  #
  # @return [void]
  #
  # @api public
  def create_method_argument_element(pre, param, mlen)
    spacer = '&nbsp;&nbsp;&nbsp;&nbsp;'
    complex_class = param.find_complex_class_name
    use_spacer = mlen > 1 ? true : false
    if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
      pre << "#{use_spacer ? spacer : ''}<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
    else
      create_method_argument_complex_element(pre, param, use_spacer, spacer, complex_class)
    end
  end

  # displayes an argument of a method as complex type and determines if is an array of types or not
  #
  # @param [Array] pre Array that contains the content that will be appended to the xml
  # @param [WashOut::Param] param the parameter what needs to be displayed
  # @param [Bololean] use_spacer  Determines if we need a spacer when appending the html or not
  # @param [String] spacer  the spacer that needs to be prepended if use_spacer is true
  # @param [Class] complex_class  The name of the complex type
  #
  # @return [void]
  #
  # @api public
  def create_method_argument_complex_element(pre, param, use_spacer, spacer, complex_class)
    return if complex_class.nil?
    argument_content = param.multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    pre << "#{use_spacer ? spacer : ''}<a href='##{complex_class}'><span class='lightBlue'>#{argument_content}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
  end

  # this method will check if the current index of the argument is not last, will insert a comma  then a break if the argument is followed by other arguments,
  # and if  the current index is equal to the size of argyments, will display a ')' sign
  #
  # @param [Builder::XmlMarkup] xml the markup builder that is used to insert HTML line breaks or span elements
  # @param [Integer] j the index of the previous argument that was displayed (
  # @param [Integer] mlen  This determines how many arguments the method that is displayed has
  #
  # @return [String]
  #
  # @api public
  def create_argument_element_spacer(xml, j, mlen)
    if j < (mlen - 1)
      xml.span ', '
    end
    if mlen > 1
      xml.br
    end
    return unless (j + 1) == mlen
    xml.span('class' => 'bold') { |y| y << ')' }
  end

  # this method will go through each of the arguments print them and then check if we need a spacer after it
  #
  #  @see #create_method_argument_element
  #  @see #create_argument_element_spacer
  #
  # @param [Builder::XmlMarkup] xml the markup builder that is used to insert HTML line breaks or span elements
  # @param [Array] pre  The array that holds the html that will be appended to the xml
  # @param [Array] input  An array with arguments
  #
  # @return [String]
  #
  # @api public
  def create_html_public_method_arguments(xml, pre, input)
    mlen = input.size
    xml.br if mlen > 1
    return unless mlen > 0
    input.each_with_index do |element, index|
      create_method_argument_element(pre, element, mlen)
      create_argument_element_spacer(xml, index, mlen)
    end
  end
end
