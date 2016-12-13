require File.expand_path("../lib/washout_builder/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "washout_builder"
  s.version     = WashoutBuilder.gem_version
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
  s.add_runtime_dependency 'wash_out', '>= 0.9.1', '>= 0.9.1'
  s.add_runtime_dependency 'activesupport', '>= 4.0', '>= 4.0'

  s.add_development_dependency 'wasabi', '~> 3.5', '>= 3.5'
  s.add_development_dependency 'savon', '~> 2.11', '>= 2.11'
  s.add_development_dependency 'httpi', '~> 2.4', '>= 2.4'
  s.add_development_dependency 'nokogiri', '~> 1.6', '>= 1.6'

  s.add_development_dependency 'hashdiff', '~> 0.3', '>= 0.3'
  s.add_development_dependency 'rspec-rails', '~> 3.5', '>= 3.5'
  s.add_development_dependency 'appraisal', '~> 2.1', '>= 2.1'
  s.add_development_dependency 'simplecov', '~> 0.12', '>= 0.12'
  s.add_development_dependency 'simplecov-summary', '~> 0.0.5', '>= 0.0.5'
  s.add_development_dependency 'mocha','~> 1.2', '>= 1.2'
  s.add_development_dependency 'coveralls','~> 0.8', '>= 0.8'

  s.add_development_dependency 'yard', '>= 0.8', '~> 0.8'
  s.add_development_dependency 'yard-rspec', '~> 0.1', '>= 0.1'
  s.add_development_dependency 'redcarpet', '~> 3.3', '>= 3.3'
  s.add_development_dependency 'github-markup', '~> 1.4', '>= 1.4'
  s.add_development_dependency 'inch', '~> 0.7'
end
