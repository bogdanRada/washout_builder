if object.is_a?(Class) 
  xml.h3  { |pre| pre << "#{object} #{ancestors.blank? ? "" : "<small>(extends <a href='##{ancestors[0].to_s.classify}'>#{ancestors[0].to_s.classify}</a>)</small>" } " }
  xml.a("name" => "#{object}") {}
  xml.ul("class" => "pre") {
    structure.each do |attribute, attr_details|
      create_html_fault_model_element_type(xml, attribute, attr_details)
    end
  }
end