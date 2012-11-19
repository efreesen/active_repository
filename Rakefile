#!/usr/bin/env rake
require "bundler/gem_tasks"

desc 'Default: run rspec tests.'
task :default => [:travis]

task :travis do
  cmd = "rspec spec"
  puts "Starting to run `#{cmd}`..."
  system("export DISPLAY=:99.0 && bundle exec rspec spec -c")
  raise "#{cmd} failed!" unless $?.exitstatus == 0
end