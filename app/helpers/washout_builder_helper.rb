module WashoutBuilderHelper

  def create_html_complex_types(xml, types)
    types.each  { |hash| create_complex_type_html(xml, hash[:obj], hash[:class], hash[:ancestors]) }
  end



  def create_complex_type_html(xml, param, class_name, ancestors)
    unless param.blank?
      xml.a( "name" => "#{class_name}")  { }
      xml.h3  { |pre| pre << "#{class_name} #{ancestors.blank? ? "" : "<small>(extends <a href='##{ancestors[0].to_s.classify}'>#{ancestors[0].to_s.classify}</a>)</small>" } " }

      if param.is_a?(WashOut::Param)
        xml.ul("class" => "pre") {
          
          param.map.each do |element|
            element.type = "string" if element.type == "text"
            # raise YAML::dump(element) if class_name.include?("ype") and element.name == "members"
            xml.li { |pre|
              if WashoutBuilder::Type::BASIC_TYPES.include?(element.type)
                element.type = "integer" if element.type == "int"
                pre << "<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"
              else
                complex_class = element.get_complex_class_name
                unless  complex_class.nil?
                  if  element.multiplied == false
                    pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
                  else
                    pre << "<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>&nbsp;<span class='bold'>#{element.name}</span>"
                  end
                end
              end
            }

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

  

  
  def create_html_virtus_model_type(xml, param, fault_structure, ancestors)
    if param.is_a?(Class) 
      xml.h3 { |pre| pre << "#{param} #{ancestors.blank? ? "" : "<small>(extends <a href='##{ancestors[0].to_s.classify}'>#{ancestors[0].to_s.classify}</a>)</small>" } " }
      xml.a("name" => "#{param}") {}
      xml.ul("class" => "pre") {
       
     
        fault_structure.each do |attribute, attr_details|
          xml.li { |pre|
            if WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase) || attr_details[:primitive] == "nilclass" 
              pre << "<span class='blue'>#{attr_details[:primitive].to_s.downcase == "nilclass" ? "string" : attr_details[:primitive].to_s.downcase }</span>&nbsp;<span class='bold'>#{attribute}</span>"
              
            else
              if  attr_details[:primitive].to_s.downcase == "array"
                
                attr_primitive =  WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:member_type].to_s.downcase) ? attr_details[:member_type].to_s.downcase : attr_details[:member_type]
                pre << "<a href='##{attr_primitive}'><span class='lightBlue'>Array of #{attr_primitive}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
              else
                pre << "<a href='##{attr_details[:primitive] }'><span class='lightBlue'>#{attr_details[:primitive]}</span></a>&nbsp;<span class='bold'>#{attribute}</span>"
              end
            end
          }
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



  def create_html_public_method(xml, operation, formats)
    # raise YAML::dump(formats[:in])
    xml.h3 "#{operation}"
    xml.a("name" => "#{operation}") {}


    xml.p("class" => "pre"){ |pre|
      unless formats[:out].nil?
        complex_class = formats[:out][0].get_complex_class_name  
        if WashoutBuilder::Type::BASIC_TYPES.include?(formats[:out][0].type)
          xml.span("class" => "blue") { |y| y<<  "#{formats[:out][0].type}" }
        else
          unless complex_class.nil?
            if  formats[:out][0].multiplied == false
              pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>"
            else
              pre << "<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>"
            end
          end
        end
      else
        pre << "void"
      end
      
      xml.span("class" => "bold") {|y|  y << "#{operation} (" }
      mlen = formats[:in].size
      xml.br if mlen > 1
      spacer = "&nbsp;&nbsp;&nbsp;&nbsp;"
      if mlen > 0
        j=0
        while j<mlen
          param = formats[:in][j]
          complex_class = param.get_complex_class_name  
          use_spacer =  mlen > 1 ? true : false
          if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
            pre << "#{use_spacer ? spacer: ''}<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
          else
            unless complex_class.nil?
              if  param.multiplied == false
                pre << "#{use_spacer ? spacer: ''}<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
              else
                pre << "#{use_spacer ? spacer: ''}<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
              end
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



    }
    xml.p "#{formats[:description]}" if !formats[:description].blank?
    xml.p "Parameters:"

    xml.ul {
      j=0
      mlen = formats[:in].size
      while j<mlen
        param = formats[:in][j]
        complex_class = param.get_complex_class_name  
        xml.li("class" => "pre") { |pre|
          if WashoutBuilder::Type::BASIC_TYPES.include?(param.type)
            pre << "<span class='blue'>#{param.type}</span>&nbsp;<span class='bold'>#{param.name}</span>"
          else
            unless complex_class.nil?
              if  param.multiplied == false
                pre << "<a href='##{complex_class}'><span class='lightBlue'>#{complex_class}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
              else
                pre << "<a href='##{complex_class}'><span class='lightBlue'>Array of #{complex_class}</span></a>&nbsp;<span class='bold'>#{param.name}</span>"
              end
            end
          end
        }
        j+=1
      end

    }

    xml.p "Return value:"
    xml.ul {
      xml.li {
        unless formats[:out].nil?
          complex_class = formats[:out][0].get_complex_class_name  
          if WashoutBuilder::Type::BASIC_TYPES.include?(formats[:out][0].type)
            xml.span("class" => "pre") { |xml| xml.span("class" => "blue") { |sp| sp << "#{formats[:out][0].type}" } }
          else
            unless complex_class.nil?
              if  formats[:out][0].multiplied == false
                xml.span("class" => "pre") { xml.a("href" => "##{complex_class}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"#{complex_class}" } } }
              else
                xml.span("class" => "pre") { xml.a("href" => "##{complex_class}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"Array of #{complex_class}" } } }
              end
            end
          end
        else
          xml.span("class" => "pre") { |sp| sp << "void" }
        end

      }
    }
    unless formats[:raises].blank?
      faults = formats[:raises]
      faults = [formats[:raises]] if !faults.is_a?(Array)
      
      faults = faults.select { |x| x.is_a?(Class) && (x.ancestors.include?(WashOut::SOAPError) ||  x.ancestors.include?(SOAPError) ) }
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

end
