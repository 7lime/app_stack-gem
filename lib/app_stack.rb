# encoding: utf-8

require 'yaml'
require 'find'
require 'fileutils'
require 'ostruct'
require 'tilt/erb'
require 'active_support/core_ext/hash/deep_merge'

require 'term/ansicolor'
# mixin String class for term-color methods
class String; include Term::ANSIColor end

## A namespace for app-stack based modules
module AppStack
  CONF_FILE = '.app_stack.yml'

  # public entry ponit, receive a configuration filename,
  # copy source files on to the directory contains the
  # configuration file.
  def stackup!(conf_file)
    load_configuration(conf_file)

    # register_self
    # merge_stack!(stack_app)

    # rewrite configuration back to app-stack file
    @config['files'] = @files
    File.open(file, 'wb') { |fh| fh.puts YAML.dump(@config) }
  end

  # convert directory names, load configuration from yaml file
  def load_configuration(conf_file)
    @conf_file = conf_file || CONF_FILE
    @config = YAML.load(File.read(@conf_file))

    @app_root = @config['app_root'] || File.dirname(@conf_file)
    @app_root = File.expand_path(@app_root)
    @stack_dir = @config['stack_dir'] || '../stack_apps'
    @stack_dir = File.expand_path(@app_root + '/' +
                      @stack_dir) if @stack_dir.match(/^\.\.?\//)

    @files = @config['files'] || {}
  end



  # use module variables, skip `new`
  # rubocop:disable ModuleFunction
  extend self
end
