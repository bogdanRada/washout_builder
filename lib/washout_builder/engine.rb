module WashoutBuilder
  class Engine < ::Rails::Engine
    initializer "wash_out.configuration" do |app|
      app.routes.append do
        match "/washout"   => "washout_builder#all", :via => :get, :format => false
      end
      if app.config.wash_out[:catch_xml_errors]
        app.config.middleware.insert_after 'ActionDispatch::ShowExceptions',  WashOut::Middleware  if defined?(WashOut::Middleware)
        app.config.middleware.insert_after 'ActionDispatch::ShowExceptions',  WashOut::Middlewares::Catcher  if defined?(WashOut::Middlewares::Catcher)
      end
    end
end
end
