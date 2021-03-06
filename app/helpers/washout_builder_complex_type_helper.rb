# module that is used for constructing complex types in HTML-Documentation
module WashoutBuilderComplexTypeHelper
  include WashoutBuilderSharedHelper
  # this method is for printing the attributes of a complex type
  # if the attributes are primitives this will show the attributes with  blue color
  # otherwise will call another method for printing the complex attribute
  # @see WashoutBuilder::Type::BASIC_TYPES
  # @see #create_complex_element_type_html
  #
  # @param [Array] pre Array that contains the content that will be appended to the xml element li
  # @param [WashOut::Param] element  the element that needs to be printed
  #
  # @return [void]
  #
  # @api public
  def create_element_type_html(pre, element, element_description)
    element_description = element_description.blank? ? nil : element_description.fetch(element.name.to_s.downcase, '')
    element.type = 'string' if element.type == 'text'
    element.type = 'integer' if element.type == 'int'
    if WashoutBuilder::Type::BASIC_TYPES.include?(element.type)
      pre << "<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"
      pre << "&#8194;<span>#{html_safe(element_description)}</span>" unless element_description.blank?
      pre
    else
      create_complex_element_type_html(pre, element, element_description)
    end
  end

  # used for escaping strings
  # @param [String] string The string that needs to be escaped
  #
  # @return [String]
  #
  # @api public
  def html_safe(string)
    string.present? ? ActiveSupport::SafeBuffer.new(string) : string
  end

  # checks if a complex attribute of a complex type is a array or not
  # and retrieves the complex class name of the attribute and prints it
  # @see WashoutBuilder::Document::ComplexType#find_complex_class_name
  # @see WashOutParam#multiplied
  #
  # @param [Array] pre Array that contains the content that will be appended to the xml element li
  # @param [WashOut::Param] element  the element that needs to be printed
  #
  # @return [void]
  #
  # @api public
  def create_complex_element_type_html(pre, element, element_description)
    complex_class = element.find_complex_class_name
    return if complex_class.nil?
    real_class = find_correct_complex_type(complex_class)
    complex_class_content = element.multiplied ? "Array of #{real_class}" : "#{real_class}"
    pre << "<a href='##{real_class}'><span class='lightBlue'>#{complex_class_content}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
    pre << "&#8194;<span>#{html_safe(element_description)}</span>" unless element_description.blank?
    pre
  end
end
