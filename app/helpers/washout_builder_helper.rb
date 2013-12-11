module WashoutBuilderHelper
  include WashOutHelper

  def get_complex_class_name(p, defined = [])
    complex_class =  p.struct? ? p.basic_type : nil
    complex_class =  complex_class.include?(".") ? complex_class.gsub(".","/").camelize : complex_class.to_s.classify    unless complex_class.nil?
     
    unless complex_class.nil? || defined.blank?
     
      complex_obj_found = defined.detect {|hash|   hash[:class] == complex_class}
    
      if !complex_obj_found.nil? && p.struct?  &&  !p.classified? && p.source_class_name.blank?
        raise RuntimeError, "Duplicate use of `#{p.basic_type}` type name. Consider using classified types."
      end
    end
   
    return complex_class
  end

  
  def get_param_structure(param)
    param.map.inject({}) {|h,element|  h[element.name] = element.type;h }
  end
  
  
  def remove_type_inheritable_elements(param, keys)
    param.map.delete_if{|element|  keys.include?(element.name) }
  end
  
  
  def  same_structure_as_ancestor?(param, ancestor)
    param_structure = get_param_structure(param)
    ancestor_structure = get_param_structure(ancestor)
    if  param_structure.keys == ancestor_structure.keys
      return true
    else 
      remove_type_inheritable_elements(param, ancestor_structure.keys)
      return false
    end
  end
  
  
  
  
  def get_class_ancestors(param,class_name, defined)
    bool_the_same = false
    param_class = class_name.is_a?(Class) ? class_name : class_name.constantize rescue nil
    unless param_class.nil?
      ancestors  = (param_class.ancestors - param_class.included_modules).delete_if{ |x| x.to_s.downcase == class_name.to_s.downcase  ||  x.to_s == "ActiveRecord::Base" ||  x.to_s == "Object" || x.to_s =="BasicObject" || x.to_s == "WashOut::Type" }
      unless ancestors.blank?
        ancestor_structure =  { ancestors[0].to_s.downcase =>  ancestors[0].columns_hash.inject({}) {|h, (k,v)|  h["#{k}"]="#{v.type}".to_sym; h } }
        ancestor_object =  WashOut::Param.parse_def(@soap_config,ancestor_structure)[0]
        bool_the_same = same_structure_as_ancestor?(param, ancestor_object)
        unless bool_the_same
          top_ancestors = get_class_ancestors(ancestor_class, defined)
          defined << {:class =>ancestor_class.to_s, :obj =>ancestor_object ,  :ancestors => top_ancestors   }
        end
      end
      ancestors unless  bool_the_same
    end
  end
  
  
  def fix_descendant_wash_out_type(param, complex_class)
    param_class = complex_class.is_a?(Class) ? complex_class : complex_class.constantize rescue nil
    if !param_class.nil? && param_class.ancestors.include?(WashOut::Type) && !param.map[0].nil? 
      descendant = WashOut::Param.parse_def(@soap_config, param_class.wash_out_param_map)[0]
      param.name =  descendant.name 
      param.map = descendant.map
    end
  end

  def get_nested_complex_types(param, defined)
    defined = [] if defined.blank?
    complex_class = get_complex_class_name(param, defined)
    fix_descendant_wash_out_type(param, complex_class)
    defined << {:class =>complex_class, :obj => param, :ancestors => param.classified?  ?  get_class_ancestors(param, complex_class, defined) : nil } unless complex_class.nil?
    if param.struct?
      c_names = []
      param.map.each { |obj|   c_names.concat(get_nested_complex_types(obj, defined))  }        
      defined.concat(c_names)
    end
    defined.sort_by { |hash| hash[:class].downcase }.uniq unless defined.blank?
  end


  def get_complex_types(map)
    defined = []
    map.each do |operation, formats|
      (formats[:in] + formats[:out]).each do |p|
        defined.concat(get_nested_complex_types(p, defined))
      end
    end
    defined.sort_by { |hash| hash[:class].downcase }.uniq unless defined.blank?
  end

  
  def remove_fault_type_inheritable_elements(param, keys)
    get_virtus_model_structure(param).delete_if{|key,value|  keys.include?(key) }
  end
  
  
 
  
  
  def get_fault_class_ancestors(fault, defined, debug = false)
    bool_the_same = false
    unless fault.nil?
      ancestors  = (fault.ancestors - fault.included_modules).delete_if{ |x| x.to_s.downcase == fault.to_s.downcase  ||  x.to_s == "ActiveRecord::Base" ||  x.to_s == "Object" || x.to_s =="BasicObject"   || x.to_s == "Exception" }
      if  ancestors.blank?
        defined << {:fault => fault,:structure =>get_virtus_model_structure(fault)  ,:ancestors => []   }
      else
       fault_structure =  remove_fault_type_inheritable_elements(fault,  get_virtus_model_structure(ancestors[0]).keys)
       defined << {:fault => fault,:structure =>fault_structure  ,:ancestors => ancestors  }
        get_fault_class_ancestors(ancestors[0], defined)
      end
      ancestors unless  bool_the_same
    end
  end
  
  def get_virtus_model_structure(fault)
    fault.attribute_set.inject({}) {|h, elem|  h["#{elem.name}"]= { :primitive => "#{elem.primitive}", :options => elem.options }; h }
  end
 
  
  def get_fault_types(map)
    defined = map.select{|operation, formats| !formats[:raises].blank? }
    defined = defined.collect {|operation, formats|  formats[:raises].is_a?(Array)  ? formats[:raises] : [formats[:raises]] }.flatten.select { |x| x.is_a?(Class) && x.ancestors.include?(WashOut::SOAPError) }  unless defined.blank?
    fault_types = []
    defined << WashOut::SOAPError
    defined.each{ |item|  get_fault_class_ancestors(item, fault_types, true)}  unless   defined.blank?
    fault_types = fault_types.sort_by { |hash| hash[:fault].to_s.downcase }.uniq unless fault_types.blank?
    complex_types = []
    fault_types.each do |hash| 
      hash[:structure].each do |attribute, attr_details|
        if  attr_details[:primitive].to_s.downcase == "array" &&  !WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:options][:member_type].primitive.to_s.downcase)
          complex_class = attr_details[:options][:member_type].primitive
        elsif attr_details[:primitive].to_s.downcase != "array" &&  !WashoutBuilder::Type::BASIC_TYPES.include?(attr_details[:primitive].to_s.downcase)
          complex_class = attr_details[:primitive]
        end
       
        param_class = complex_class.is_a?(Class) ? complex_class : complex_class.constantize rescue nil
        if !param_class.nil? && param_class.ancestors.include?(Virtus::Model::Core)
           get_fault_class_ancestors(param_class, complex_types)
        elsif !param_class.nil? && !param_class.ancestors.include?(Virtus::Model::Core)
          raise RuntimeError, "Non-existent use of `#{param_class}` type name or this class does not use Virtus.model. Consider using classified types that include Virtus.mode for exception atribute types."
        end
        
      end 
    end
    complex_types = complex_types.sort_by { |hash| hash[:fault].to_s.downcase }.uniq unless complex_types.blank?
    [fault_types, complex_types]
  end

  def get_soap_action_names(map)
    map.map{|operation, formats| operation.to_s }.sort_by { |name| name.downcase }.uniq unless map.blank?
  end


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
                pre << "<span class='blue'>#{element.type}</span>&nbsp;<span class='bold'>#{element.name}</span>"
              else
                complex_class = get_complex_class_name(element)
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
                attr_primitive = attr_details[:options][:member_type].primitive.to_s
                
                attr_primitive =  WashoutBuilder::Type::BASIC_TYPES.include?(attr_primitive.downcase) ? attr_primitive.downcase : attr_primitive
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
      if !formats[:out].nil?
        if WashoutBuilder::Type::BASIC_TYPES.include?(formats[:out][0].type)
          xml.span("class" => "blue") { |y| y<<  "#{formats[:out][0].type}" }
        else
          xml.a("href" => "##{formats[:out][0].type}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"#{formats[:out][0].type}" } }
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
          complex_class = get_complex_class_name(param)  
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
        complex_class = get_complex_class_name(param)  
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
        if !formats[:out].nil?

          if WashoutBuilder::Type::BASIC_TYPES.include?(formats[:out][0].type)
            xml.span("class" => "pre") { |xml| xml.span("class" => "blue") { |sp| sp << "#{formats[:out][0].type}" } }
          else
            xml.span("class" => "pre") { xml.a("href" => "##{formats[:out][0].type}") { |xml| xml.span("class" => "lightBlue") { |y| y<<"#{formats[:out][0].type}" } } }
          end
        else
          xml.span("class" => "pre") { |sp| sp << "void" }
        end

      }
    }
    unless formats[:raises].blank?
      faults = formats[:raises]
      faults = [formats[:raises]] if !faults.is_a?(Array)
      
      faults = faults.select { |x| x.is_a?(Class) && x.ancestors.include?(WashOut::SOAPError) }
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
