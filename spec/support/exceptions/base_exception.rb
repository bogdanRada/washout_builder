Dir["#{File.dirname(__FILE__)}/**/*.rb"].each { |f| require f }
class BaseException < AnotherException
  
  attribute :custom_attribute, String
  attribute :other_custom_attribute, Integer
  attribute :errors,Array[Integer]
  attribute :custom, Array[ExModel]
  attribute :custom2, ExModel
  attribute :errors_2, Array[Custom2]
  attribute :error, Custom2
  attribute :module, NameModel
  attribute :geo, ValueObjectModel
  
end
 
