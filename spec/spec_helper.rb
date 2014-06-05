# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'codeclimate-test-reporter'
require 'simplecov'
require 'simplecov-summary'
require 'coveralls'
 
formatters = [SimpleCov::Formatter::HTMLFormatter]

formatters << Coveralls::SimpleCov::Formatter if ENV['TRAVIS']
formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN'] && ENV['TRAVIS']
 
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]


Coveralls.wear!
SimpleCov.start do
  add_filter 'spec'
  add_group 'Library', 'lib'
  add_group 'App', 'app'

  at_exit do; end
end

require 'active_support'
require 'nori'
require 'nokogiri'
require 'ostruct'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.expand_path("../../config/routes.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"
require 'rspec/autorun'
require "savon"
require 'wash_out'

require 'capybara/rspec'
require 'capybara/rails'
require 'headless'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.infer_spec_type_from_file_location!
  
  config.before(:suite) do
    # Blocks all remote HTTP requests by default, they need to be stubbed.
    if !RUBY_PLATFORM.downcase.include?('darwin') && !ENV['NO_HEADLESS']
      Headless.new(reuse: false, destroy_on_exit: false).start
    end
  end
  
  config.mock_with :mocha
  config.before(:all) do
    WashoutBuilder::Engine.config.wash_out = {
      snakecase_input: false,
      camelize_wsdl: false,
      namespace: false
    }
  end

  config.after(:suite) do
    if SimpleCov.running
      silence_stream(STDOUT) do
        SimpleCov::Formatter::HTMLFormatter.new.format(SimpleCov.result)
      end

      SimpleCov::Formatter::SummaryFormatter.new.format(SimpleCov.result)
    end
  end
end

HTTPI.logger = Logger.new(open("/dev/null", 'w'))
HTTPI.adapter = :rack

HTTPI::Adapter::Rack.mount 'app', Dummy::Application
Dummy::Application.routes.draw do
  wash_out :api
end

def mock_controller(options = {}, &block)
  Object.send :remove_const, :ApiController if defined?(ApiController)
  Object.send :const_set, :ApiController, Class.new(ApplicationController) {
    soap_service options.reverse_merge({
        snakecase_input: true,
        camelize_wsdl: true,
        namespace: false
      })
    class_exec &block if block
  }

  ActiveSupport::Dependencies::Reference.instance_variable_get(:'@store').delete('ApiController')
end

def base_exception
  WashOut::Dispatcher::SOAPError
end


class WashoutBuilderTestError < base_exception
  
  
end

def get_wash_out_param(class_name_or_structure, soap_config = soap_config)
  WashOut::Param.parse_builder_def(soap_config, class_name_or_structure)[0]
end