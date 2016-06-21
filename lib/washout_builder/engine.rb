module WashoutBuilder
  # the engine that is used to mount inside the rails application
  class Engine < ::Rails::Engine
    isolate_namespace WashoutBuilder
    config.washout_builder = ActiveSupport::OrderedOptions.new
    initializer 'washout_builder.configuration' do |app|
      blacklisted_envs = app.config.washout_builder[:blacklisted_envs]
      blacklisted_envs = blacklisted_envs.is_a?(Array) ? blacklisted_envs : [blacklisted_envs].compact
      whitelisted_envs = app.config.washout_builder[:whitelisted_envs]
      whitelisted_envs = whitelisted_envs.is_a?(Array) ? whitelisted_envs : [whitelisted_envs].compact
      mounted_path = app.config.washout_builder[:mounted_path]
      if (whitelisted_envs.present? || blacklisted_envs.present?) && whitelisted_envs.find{|a| blacklisted_envs.include?(a) }.blank?
        if whitelisted_envs.include?('*') || (!blacklisted_envs.include?(Rails.env) || whitelisted_envs.include?(Rails.env))
          app.routes.append do
            mount WashoutBuilder::Engine => mounted_path if mounted_path.is_a?(String) && mounted_path.starts_with?('/')
          end
        end
      end
    end
  end
end
