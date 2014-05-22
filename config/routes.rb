WashoutBuilder::Engine.routes.draw do
   match '/:name'  => "washout_builder#all",   :as => :root, :via => :get
end