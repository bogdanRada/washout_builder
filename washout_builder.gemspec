require 'date'
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

  s.required_ruby_version = '>= 2.2.2'

  s.add_runtime_dependency 'wash_out', '>= 0.9.1', '>= 0.9.1'
  s.add_runtime_dependency 'activesupport', '>= 4.0', '>= 4.0'
end
