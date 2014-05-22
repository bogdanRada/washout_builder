WashoutBuilder::Engine.routes.draw do
  match "/"  => "washout_builder#all",   :as => :root, :via => :get
  match "/:name"=> "washout_builder#all",   :as => :washout_builder_service, :via => :get
end