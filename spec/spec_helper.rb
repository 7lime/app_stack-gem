# encoding: utf-8
require 'simplecov'
SimpleCov.start do
  coverage_dir 'docs/coverage'
end

require 'rspec'
require 'app_stack'

# mixin-up, add stub-reader for testing
module AppStack
  attr_reader :config, :app_root, :stack_dir, :files
  attr_accessor :verbose
end

# file test
