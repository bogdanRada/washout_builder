
unless object.blank?
  xml.a( "name" => "#{class_name}")  { }
  xml.h3  { |pre| pre << "#{class_name} #{ancestors.blank? ? "" : "<small>(extends <a href='##{ancestors[0].to_s.classify}'>#{ancestors[0].to_s.classify}</a>)</small>" } " }


  if WashoutBuilder::Type.all_param_classes.include?(object.class)
    xml.ul("class" => "pre") {
      object.map.each do |element|
        xml.li { |pre|
          create_element_type_html(pre, element)
        }
      end
    }
  end
end
