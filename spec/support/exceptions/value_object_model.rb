class ValueObjectModel
  include Virtus.value_object

  values do
    attribute :latitude,  Float
    attribute :longitude, Float
  end
end