class Api::Fluffy < WashOut::Type
  map universe: {
    name: :string,
    age: :int
  }
end
