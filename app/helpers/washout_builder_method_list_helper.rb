# helper that is used to list the method's return tyep as a LI element in HTML documentation
module WashoutBuilderMethodListHelper
  include WashoutBuilderSharedHelper
  # this method will create the return type of the method and check if the type is basic or complex type or array of types
  #
  # @param [Builder::XmlMarkup] xml the markup builder that is used to insert HTML line breaks or span elements
  # @param [Array] complex_class  The array that holds the html that will be appended to the xml
  # @param [Array<WashOut::Param>] builder_out  An array of params ( will contain a single position in the array) this is used to determine if the class is an array or not
  #
  # @return [String]
  #
  # @api public
  def create_return_complex_type_list_html(xml, complex_class, builder_out)
    real_class = find_correct_complex_type(complex_class)
    return_content = builder_out[0].multiplied ?  "Array of #{real_class}" : "#{real_class}"
    xml.span('class' => 'pre') do
      xml.a('href' => "##{real_class}") do |inner_xml|
        inner_xml.span('class' => 'lightBlue') do |y|
          y << "#{return_content}"
        end
      end
    end
  end

  # this method will go through each of the arguments print them and then check if we need a spacer after it
  # @see WashoutBuilder::Document::ComplexType#find_complex_class_name
  # @see WashoutBuilder::Type::BASIC_TYPES
  # @see #create_return_complex_type_list_html
  #
  # @param [Builder::XmlMarkup] xml the markup builder that is used to insert HTML line breaks or span elements
  # @param [Array<WashOut::Param>] output t  An array of params that need to be displayed, will check the type of each and will display it accordingly if is complex type or not
  #
  # @return [String]
  #
  # @api public
  def create_return_type_list_html(xml, output)
    if output.nil? || output[0].blank?
      xml.span('class' => 'pre') { |sp| sp << 'void' }
    else
      complex_class = output[0].find_complex_class_name
      if WashoutBuilder::Type::BASIC_TYPES.include?(output[0].type)
        xml.span('class' => 'pre') do |inner_xml|
          inner_xml.span('class' => 'blue') do |sp|
            sp << "#{output[0].type}"
          end
        end
      else
        create_return_complex_type_list_html(xml, complex_class, output) unless complex_class.nil?
      end
    end
  end
end
