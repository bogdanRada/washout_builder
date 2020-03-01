module Api
  class TestType < WashOut::Type
    map project: {
      name: :string,
      title: :string,
      users: [{ mail: :string }],
    }
  end
end
