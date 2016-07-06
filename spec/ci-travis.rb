#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
puts ENV['BUNDLE_GEMFILE']
puts ARGV[0]

appraisal_name = ENV['BUNDLE_GEMFILE'].scan(/rails\_(.*)\.gemfile/).flatten.first
command_prefix = "appraisal rails-#{appraisal_name}"
exec ("#{command_prefix} bundle install && #{command_prefix} bundle exec rspec && bundle exec rake coveralls:push ")
