# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'simplecov-summary'
require 'coveralls'
# require "codeclimate-test-reporter"
formatters = [SimpleCov::Formatter::HTMLFormatter]

formatters << Coveralls::SimpleCov::Formatter # if ENV['TRAVIS']
# formatters << CodeClimate::TestReporter::Formatter # if ENV['CODECLIMATE_REPO_TOKEN'] && ENV['TRAVIS']

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)

Coveralls.wear!
SimpleCov.start 'rails' do
  add_filter 'spec'
  # add_group 'Library', 'lib'
  # add_group 'App', 'app'

  at_exit {}
end

# CodeClimate::TestReporter.configure do |config|
#  config.logger.level = Logger::WARN
# end
# CodeClimate::TestReporter.start

require 'active_support'
require 'nori'
require 'nokogiri'
require 'ostruct'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require File.expand_path('../../config/routes.rb', __FILE__)
require 'rspec/rails'
require 'savon'
require "pry"
require 'wash_out'


Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.infer_spec_type_from_file_location!

  config.mock_with :mocha
  config.before(:all) do
    WashoutBuilder::Engine.config.wash_out = {
      snakecase_input: false,
      camelize_wsdl: false,
      namespace: false
    }
  end
  # config.expect_with(:rspec) { |c| c.syntax = :should }

  config.after(:suite) do
    if SimpleCov.running
      silence_stream(STDOUT) do
        SimpleCov::Formatter::HTMLFormatter.new.format(SimpleCov.result)
      end

      SimpleCov::Formatter::SummaryFormatter.new.format(SimpleCov.result)
    end
  end
end

HTTPI.logger = Logger.new(open('/dev/null', 'w'))
HTTPI.adapter = :rack

HTTPI::Adapter::Rack.mount 'app', Dummy::Application
Dummy::Application.routes.draw do
  wash_out :api
end

def mock_controller(options = {}, &block)
  Object.send :remove_const, :ApiController if defined?(ApiController)
  Object.send :const_set, :ApiController, Class.new(ApplicationController) {
    soap_service options.reverse_merge(snakecase_input: true,
                                       camelize_wsdl: true,
                                       namespace: false)
    class_exec(&block) if block
  }

  ActiveSupport::Dependencies::Reference.instance_variable_get(:'@store').delete('ApiController')
end

def base_exception
  WashOut::Dispatcher::SOAPError
end

class WashoutBuilderTestError < base_exception
end

def get_wash_out_param(class_name_or_structure, soap_config = OpenStruct.new(
  camelize_wsdl: false,
  namespace: '/api/wsdl'
))
  WashOut::Param.parse_builder_def(soap_config, class_name_or_structure)[0]
end

class Hash
  def deep_include?(sub_hash)
    sub_hash.keys.all? do |key|
      if check_key_type(key, Hash)
        sub_hash[key].is_a?(Hash) && self[key].deep_include?(sub_hash[key])
      elsif check_key_type(key, Array)
        sub_hash[key].is_a?(Array) && deep_include_array(key, sub_hash)
      else
        self[key] == sub_hash[key]
      end
    end
  end

  def check_key_type(key, type)
    self.key?(key) && self[key].is_a?(type)
  end

  def deep_include_array(key, sub_hash)
    self[key].each_with_index do |value, index|
      if value.is_a?(Hash)
        value.deep_include?(sub_hash[key][index])
      else
        value == sub_hash[key][index]
      end
    end
  end
end

Builder::XmlBase.class_eval do

  alias_method :old_method_missing, :method_missing

  def method_missing(sym, *args, &block)
    return if ['inspect'].include?(sym.to_s)
    old_method_missing(sym, *args, &block)
  end
end

unless defined?(silence_stream) # Rails 5
  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
    old_stream.close
  end
end
