#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'
puts JSON.pretty_generate(ENV.to_hash)
puts ARGV.inspect

appraisal_name = ENV['BUNDLE_GEMFILE'].scan(/rails\_(.*)\.gemfile/).flatten.first
command_prefix = "appraisal rails-#{appraisal_name}"
exec ("#{command_prefix} bundle install && #{command_prefix} bundle exec rspec && bundle exec rake coveralls:push ")
