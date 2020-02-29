module WashoutBuilderSharedHelper
  # When displaying a complex type that inherits from WashOut::Type
  # we must use its descendant name to properly show the correct Type
  # that can we used to make the actual request to the action
  #
  # @param [Class, String] complex_class the name of the complex type either as a string or a class
  # @return [Class, String]
  # @api public
  def find_correct_complex_type(complex_class)
    real_class = find_class_from_string(complex_class)
    if real_class.present? && real_class.ancestors.include?( WashoutBuilder::Type.base_type_class)
      descendant = WashoutBuilder::Type.base_param_class.parse_def(config, real_class.wash_out_param_map)[0]
      descendant.find_complex_class_name
    else
      complex_class
    end
  end

  # Tries to constantize a string or a class to return the class
  #
  # @param [String] complex_class A string that contains the name of a class
  # @return [Class, nil] returns the class if it is classes_defined otherwise nil
  # @api public
  def find_class_from_string(complex_class)
    complex_class.is_a?(Class) ? complex_class : complex_class.constantize
  rescue
    nil
  end
end