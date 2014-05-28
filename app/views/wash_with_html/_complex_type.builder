
unless object.blank?
  xml.a( "name" => "#{class_name}")  { }
   xml.h3  { |pre| pre << "#{class_name} #{ancestors.blank? ? "" : "<small>(extends <a href='##{ancestors[0].to_s.classify}'>#{ancestors[0].to_s.classify}</a>)</small>" } " }   

  
  if object.is_a?(WashOut::Param)
    xml.ul("class" => "pre") {
      object.map.each do |element|
        create_complex_type_element_html(xml, element)
      end
    }
  end
end