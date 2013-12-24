module Api
  class TestType < WashOut::Type
    map :project => {
      :name                                    => :string,
      :description                           => :string,
      :users                                    => [{:mail => :string }],
      #  'dada'                                    => [Project]
    }
  end
end
