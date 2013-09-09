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

    register_self!(@app_root)
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

    @verbose = @config['verbose'] || 1
    @verbose = @verbose.to_i

    @files = @config['files'] || {}
  end

  # for files already in the app root, register to no-copy list
  def register_self!(dir)
    Find.find(dir).each do |f|
      next if f == dir
      basename = f.sub(/^#{dir}\//, '')
      next if basename.match(/^.git$/)
      next if basename.match(/^.git\W/)
      next if gitignore_list(dir).include?(basename)

      if @files[basename]
        carp "From #{'self'.blue.bold} #{basename.bold} ",
             'keep'.white, 2 if @files[basename] == '__self'
      else
        carp "From #{'self'.blue.bold} #{basename.bold}",
             'registed'.green.bold, 1
        @files[basename] = '__self'
      end
    end
  end

  # private utility functions

  # print debug / information message to console based on verbose level
  def carp(job, state = 'done'.bold.green, v = 1)
    return if @verbose < v
    dots = 70 - job.size
    job += ' ' + '.' * dots if dots > 0
    puts job + state
  end

  # fetch (and cache) git ignore file lists for a specific directory
  def gitignore_list(dir)
    @gitignore_list ||= {}
    @gitignore_list[dir] ||= []

    ilist = []
    if File.exists?(dir + '/.gitignore')
      File.read(dir + '/.gitignore').split("\n").each do |line|
        Dir[dir + '/' + line].each do |f|
          f.sub!(/^#{dir}\//, '')
          ilist << f unless ilist.include?(f)
        end
      end
    end
    @gitignore_list[dir] = ilist
  end

  # use module variables, skip `new`
  # rubocop:disable ModuleFunction
  extend self
end
