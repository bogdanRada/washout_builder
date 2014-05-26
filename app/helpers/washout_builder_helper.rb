module WashoutBuilderHelper

  def create_html_complex_types(xml, types)
    types.each  { |hash| create_complex_type_html(xml, hash[:obj], hash[:class], hash[:ancestors]) }
  end

  
  
  def create_element_type_html(pre, complex_class, element)
    unless  complex_class.nil?
      if  element.multiplied == false
        pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
      else
        pre << "<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
      end
    end
  end
  
    
  def create_class_type_html(xml, class_name, ancestors)
    xml.h3  { |pre| pre << "#{class_name} #{ancestors.blank? ? "" : "<small>(extends <a href='##{ancestors[0].to_s.classify}'>#{ancestors[0].to_s.classify}</a>)</small>" } " }
  end

  
  def create_complex_type_element_html(xml, element)
    element.type = "string" if element.type == "text"
    element.type = "integer" if element.type == "int"
    xml.li { |pre|
      if WashoutBuilder::Type::BASIC_TYPES.include?(element.type)
        pre << "<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"
      else
        complex_class = element.get_complex_class_name
        create_element_type_html(pre, complex_class, element)
      end
    }
  end


  def create_complex_type_html(xml, param, class_name, ancestors)
    unless param.blank?
      xml.a( "name" => "#{class_name}")  { }
     
      create_class_type_html(xml, class_name, ancestors)
      if param.is_a?(WashOut::Param)
        xml.ul("class" => "pre") {
          param.map.each do |element|
            create_complex_type_element_html(xml, element)
          end
        }
      end
    end
  end

  def create_html_fault_types_details(xml, fault_types)
    unless fault_types.blank?
      
      fault_types.each {  |hash| 
        create_html_virtus_model_type(xml, hash[:fault],hash[:structure],  hash[:ancestors]) 
      }  
    end
  end

  def create_virtus_model_complex_element_type(pre, attr_primitive, attribute, array)
    attribute_primitive = array == true ? "Array of #{attr_primitive}" : "#{attr_primitive}"
    pre << "<a href='##{attr_primitive}'><span class='lightBlue'> #{attribute_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
  end
  
  
  def create_html_virtus_model_element_type(xml, attribute, attr_details)
    xml.li { |pre|
      if WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase) || attr_details[:primitive] == "nilclass" 
        pre << "<span class='blue'>#{attr_details[:primitive].to_s.downcase == "nilclass" ? "string" : attr_details[:primitive].to_s.downcase }</span>&nbsp;<span class='bold'>#{attribute}</span>"
        
      else
        if  attr_details[:primitive].to_s.downcase == "array"
          
          attr_primitive =  WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase) ? attr_details[:member_type].to_s.downcase : attr_details[:member_type]
          create_virtus_model_complex_element_type(pre,attr_primitive, attribute, true )
        else
          create_virtus_model_complex_element_type(pre,attr_details[:primitive], attribute, false )
        end
      end
    }
  end
  
  
  def create_html_virtus_model_type(xml, param, fault_structure, ancestors)
    if param.is_a?(Class) 
      create_class_type_html(xml, param, ancestors)
      xml.a("name" => "#{param}") {}
      xml.ul("class" => "pre") {
        fault_structure.each do |attribute, attr_details|
          create_html_virtus_model_element_type(xml, attribute, attr_details)
        end
      }
    end
  end

  def create_html_public_methods(xml, map)
    unless map.blank?
      map =map.sort_by { |operation, formats| operation.downcase }.uniq
      map.each {  |operation, formats| create_html_public_method(xml, operation, formats) }
    end
  end

  
  def create_return_complex_type_html(xml, complex_class, builder_out)
    return_content =  builder_out[0].multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    xml.span("class" => "pre") { xml.a("href" => "##{complex_class}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"#{return_content}" } } }
  end

  
  def create_return_type_html(xml, formats)
    xml.p "Return value:"
    xml.ul {
      xml.li {
        unless formats[:builder_out].nil?
          complex_class = formats[:builder_out][0].get_complex_class_name  
          if WashoutBuilder::Type::BASIC_TYPES.include?(formats[:builder_out][0].type)
            xml.span("class" => "pre") { |xml| xml.span("class" => "blue") { |sp| sp << "#{formats[:builder_out][0].type}" } }
          else
            create_return_complex_type_html(xml, complex_class, formats[:builder_out]) unless complex_class.nil?
          end
        else
          xml.span("class" => "pre") { |sp| sp << "void" }
        end
        
      }
    }
  end
  
  
  def create_parameters_html(xml, formats)
    xml.p "Parameters:"
    xml.ul {
      j=0
      mlen = formats[:builder_in].size
      while j<mlen
        param = formats[:builder_in][j]
        complex_class = param.get_complex_class_name  
        xml.li("class" => "pre") { |pre|
          if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
            pre << "<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
          else
            create_element_type_html(pre, complex_class, param)
          end
        }
        j+=1
      end
      
    }
  end
  
  def create_exceptions_list_html(xml, formats)
    unless formats[:raises].blank?
      faults = formats[:raises]
      faults = [formats[:raises]] if !faults.is_a?(Array)
      
      faults = faults.select { |x| WashoutBuilder::Type.valid_fault_class?(x)  }
      unless faults.blank?
        xml.p "Exceptions:"
        xml.ul {
          faults.each do |p|
            xml.li("class" => "pre"){ |y| y<< "<a href='##{p.to_s}'><span class='lightBlue'> #{p.to_s}</span></a>" }
          end
        }
      end
    end
  end
  
  
  def create_html_public_method_return_type(xml,pre, formats)
    unless formats[:builder_out].nil?
      complex_class = formats[:builder_out][0].get_complex_class_name  
      if WashoutBuilder::Type::BASIC_TYPES.include?(formats[:builder_out][0].type)
        xml.span("class" => "blue") { |y| y<<  "#{formats[:builder_out][0].type}" }
      else
        unless complex_class.nil?
          if  formats[:builder_out][0].multiplied == false
            pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>"
          else
            pre << "<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>"
          end
        end
      end
    else
      pre << "void"
    end
  end
  
  def create_html_public_method_arguments_complex_type(pre, spacer, use_spacer, complex_class, param)
    argument_content = param.multiplied == false ? "#{complex_class}" : "Array of #{complex_class}"
    pre << "#{use_spacer ? spacer: ''}<a href='##{complex_class}'><span class='lightBlue'>#{argument_content}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
  end
  
  def create_html_public_method_arguments(xml, pre, operation, formats)
    mlen = formats[:builder_in].size
    xml.br if mlen > 1
    spacer = "&nbsp;&nbsp;&nbsp;&nbsp;"
    if mlen > 0
      j=0
      while j<mlen
        param = formats[:builder_in][j]
        complex_class = param.get_complex_class_name  
        use_spacer =  mlen > 1 ? true : false
        if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
          pre << "#{use_spacer ? spacer: ''}<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
        else
          unless complex_class.nil?
            create_html_public_method_arguments_complex_type(pre, spacer, use_spacer, complex_class, param)
          end
        end
        if j< (mlen-1)
          xml.span ", "
        end
        if mlen > 1
          xml.br
        end
        if (j+1) == mlen
          xml.span("class" => "bold") {|y|  y << ")" }
        end
        j+=1
      end

    end
  end
  
  
  def create_html_public_method(xml, operation, formats)
    # raise YAML::dump(formats[:builder_in])
    xml.h3 "#{operation}"
    xml.a("name" => "#{operation}") {}

    xml.p("class" => "pre"){ |pre|
      create_html_public_method_return_type(xml,pre, formats)
       xml.span("class" => "bold") {|y|  y << "#{operation} (" }
      create_html_public_method_arguments(xml, pre, operation, formats)
    }
    xml.p "#{formats[:description]}" if !formats[:description].blank?
    create_parameters_html(xml, formats)
    create_return_type_html(xml, formats)
    create_exceptions_list_html(xml, formats)
  end

end
