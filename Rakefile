require 'bundler/setup'
require 'bundler/gem_tasks'
require 'appraisal'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
 # spec.rspec_opts = ['--backtrace '] 
end

#desc "Prepare dummy application"
#task :prepare do
#  ENV["RAILS_ENV"] ||= 'test'
#
#  require File.expand_path("./spec/dummy/config/environment", File.dirname(__FILE__))
#  Dummy::Application.load_tasks
#
#  Rake::Task["db:test:prepare"].invoke
#end



desc "Default: run the unit tests."
task :default => [ :all]

desc 'Test the plugin under all supported Rails versions.'
task :all => ["appraisal:install"] do |t|
  exec('rake appraisal spec')
end
