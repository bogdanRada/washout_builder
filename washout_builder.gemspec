require File.expand_path("../lib/washout_builder/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "washout_builder"
  s.version     = WashoutBuilder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "WashOut Soap Service HTML-Documentation generator (extends WashOut https://github.com/inossidabile/wash_out/)"
  s.email       = "raoul_ice@yahoo.com"
  s.homepage    = "http://github.com/bogdanRada/washout_builder/"
  s.description = "WashOut Soap Service HTML-Documentation generator (extends WashOut https://github.com/inossidabile/wash_out/) "
  s.authors     = ["bogdanRada"]
  s.date =  Date.today
  
  s.licenses = ["MIT"]
  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(/^(spec)/)
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'wash_out', '~> 0.9', '>= 0.9.1'
  
  s.add_development_dependency 'wasabi', '~> 3.3', '>= 3.3.0'
  s.add_development_dependency 'savon', '~> 2.5', '>= 2.5.1'
  s.add_development_dependency 'httpi', '~> 2.1', '>= 2.1.0'
  s.add_development_dependency 'nokogiri', '~> 1.6', '>= 1.6.0'
    
  s.add_development_dependency 'rspec-rails', '~> 2.0', '>= 2.0'
  s.add_development_dependency 'guard', '~> 2.6', '>= 2.6.1'
  s.add_development_dependency 'guard-rspec', '~> 4.2', '>= 4.2.9'
  s.add_development_dependency 'appraisal', '~> 1.0', '>= 1.0.0'
  s.add_development_dependency 'simplecov', '~> 0.8', '>= 0.8.2'
  s.add_development_dependency 'simplecov-summary', '~> 0.0', '>= 0.0.4'
  s.add_development_dependency 'mocha','~> 1.1', '>= 1.1.0'
  s.add_development_dependency 'coveralls','~> 0.7', '>= 0.7.0'
  s.add_development_dependency 'codeclimate-test-reporter','~> 0.3', '>= 0.3.0'
  s.add_development_dependency 'rvm-tester','~> 1.1', '>= 1.1.0'
  
  s.add_development_dependency 'capybara', '~> 2.2', '>= 2.2.1'
  s.add_development_dependency 'selenium-webdriver',  '~> 2.41', '>= 2.41.0'
  s.add_development_dependency 'headless','~> 1.0', '>= 1.0.1'
end
