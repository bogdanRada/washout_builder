module WashoutBuilder
  # the engine that is used to mount inside the rails application
  class Engine < ::Rails::Engine
    isolate_namespace WashoutBuilder
    initializer 'washout_builder.configuration' do |_app|
    end
  end
end
