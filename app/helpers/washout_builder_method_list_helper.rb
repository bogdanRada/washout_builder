module WashoutBuilderMethodListHelper
  def create_return_complex_type_list_html(xml, complex_class, builder_out)
    return_content = builder_out[0].multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    xml.span('class' => 'pre') do
      xml.a('href' => "##{complex_class}") do |inner_xml|
        inner_xml.span('class' => 'lightBlue') do |y|
          y << "#{return_content}"
        end
      end
    end
  end

  def create_return_type_list_html(xml, output)
    if output.nil?
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
        create_return_complex_type_html(xml, complex_class, output) unless complex_class.nil?
      end
    end
  end
end
