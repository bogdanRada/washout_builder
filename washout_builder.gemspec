require File.expand_path("../lib/washout_builder/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "washout_builder"
  s.version     = WashoutBuilder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "WashOut Soap Service Documentation builder (extends WashOut https://github.com/inossidabile/wash_out/)"
  s.email       = "raoul_ice@yahoo.com"
  s.homepage    = "http://github.com/bogdanRada/washout_builder/"
  s.description = "WashOut Soap Service Documentation builder (extends WashOut https://github.com/inossidabile/wash_out/) "
  s.authors     = ["bogdanRada"]
  s.date = "2013-11-20"
  
  s.licenses = ["MIT"]
  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(/^(spec)/)
  s.require_paths = ["lib"]
  s.add_dependency("nori", ">= 2.0.0")
  s.add_dependency("wash_out", "= 0.9.1")
end
