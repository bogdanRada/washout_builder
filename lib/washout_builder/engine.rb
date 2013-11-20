
module WashoutBuilder
  class Engine < ::Rails::Engine
    config.wash_out = ActiveSupport::OrderedOptions.new
    initializer "wash_out.configuration" do |app|
      app.routes.append do
          match "/washout"   => "washout_builder#all", :via => :get, :format => false
      end
      if app.config.wash_out[:catch_xml_errors]
        app.config.middleware.insert_after 'ActionDispatch::ShowExceptions', WashoutBuilder::Middleware
      end
    end
  end
end
