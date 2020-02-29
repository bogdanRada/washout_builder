require_relative './env_checker'
module WashoutBuilder
  # the engine that is used to mount inside the rails application
  class Engine < ::Rails::Engine
    isolate_namespace WashoutBuilder
    config.washout_builder = ActiveSupport::OrderedOptions.new

    initializer 'washout_builder.configuration' do |app|
      mounted_path = app.config.washout_builder[:mounted_path]
      if WashoutBuilder::EnvChecker.new(app).available_for_env?(Rails.env)
        app.routes.append do
          mount WashoutBuilder::Engine => mounted_path if mounted_path.is_a?(String) && mounted_path.starts_with?('/')
        end
      end
    end
  end
end
