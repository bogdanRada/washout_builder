module WashoutBuilder
  # the engine that is used to mount inside the rails application
  class Engine < ::Rails::Engine
    isolate_namespace WashoutBuilder
    config.washout_builder = ActiveSupport::OrderedOptions.new
    initializer 'washout_builder.configuration' do |app|
      if app.config.washout_builder[:mounted_path]
        app.routes.append do
          mount WashoutBuilder::Engine => app.config.washout_builder[:mounted_path]
        end
      end
    end
  end
end
