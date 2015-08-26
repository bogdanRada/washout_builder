# helper that is used to create the return types of methods in HTML documentation
module WashoutBuilderMethodReturnTypeHelper
  # this method will print the return type next to the method name
  # @see WashoutBuilder::Document::ComplexType#find_complex_class_name
  # @see WashoutBuilder::Type::BASIC_TYPES
  # @see #html_public_method_complex_type
  #
  # @param [Builder::XmlMarkup] xml the markup builder that is used to insert HTML line breaks or span elements
  # @param [Array] pre The array that contains the html that will be appended to xml
  # @param [Array<WashOut::Param>] output   An array of params that need to be displayed, will check the type of each and will display it accordingly if is complex type or not
  #
  # @return [String]
  #
  # @api public
  def create_html_public_method_return_type(xml, pre, output)
    if !output.nil? && !output[0].blank?
      complex_class = output[0].find_complex_class_name
      if WashoutBuilder::Type::BASIC_TYPES.include?(output[0].type)
        xml.span('class' => 'blue') { |y| y << "#{output[0].type}" }
      else
        html_public_method_complex_type(pre, output, complex_class)
      end
    else
      pre << 'void'
    end
  end

  # this method will go through each of the arguments print them and then check if we need a spacer after it
  #
  #
  # @param [Array] pre The array that contains the html that will be appended to xml
  # @param [Array<WashOut::Param>] output  An array of params that need to be displayed, will check the type of each and will display it accordingly if is complex type or not
  # @param [Class] complex_class the name of the complex class
  #
  # @return [void]
  #
  # @api public
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
