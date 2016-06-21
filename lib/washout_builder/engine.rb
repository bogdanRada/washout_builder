require_relative './env_checker'
module WashoutBuilder
  # the engine that is used to mount inside the rails application
  class Engine < ::Rails::Engine
    isolate_namespace WashoutBuilder
    config.washout_builder = ActiveSupport::OrderedOptions.new
    initializer 'washout_builder.configuration' do |app|
      env_checker = WashoutBuilder::EnvChecker.new(
        app.config.washout_builder[:whitelisted_envs],
        app.config.washout_builder[:blacklisted_envs]
      )
      mounted_path = app.config.washout_builder[:mounted_path]
      if env_checker.available_for_env?(Rails.env)
        app.routes.append do
          mount WashoutBuilder::Engine => mounted_path if mounted_path.is_a?(String) && mounted_path.starts_with?('/')
        end
      end
    end
  end
end
