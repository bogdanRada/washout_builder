WashoutBuilder::Engine.routes.draw do
  root :to =>"washout_builder#all"
  match   '*name'  => "washout_builder#all",   :as => :washout_builder_service, :via => :get
end