module WashoutBuilder
  class Engine < ::Rails::Engine
    isolate_namespace WashoutBuilder
    initializer "washout_builder.configuration" do |app|
      
    end
  end
end
