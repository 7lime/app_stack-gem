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
    merge_stacks!(@config['stack'])
    render_self!(@self_files)

    # rewrite configuration back to app-stack file
    @origin_config['files'] = @files
    File.open(conf_file, 'wb') { |fh| fh.puts YAML.dump(@origin_config) }
  end

  # convert directory names, load configuration from yaml file
  # rubocop:disable MethodLength
  def load_configuration(conf_file)
    @conf_file = conf_file || CONF_FILE
    @config = YAML.load(File.read(@conf_file))
    @origin_config = @config.dup

    @app_root = @config['app_root'] || File.dirname(@conf_file)
    @app_root = File.expand_path(@app_root)
    @stack_dir = @config['stack_dir'] || '../stack_apps'
    @stack_dir = File.expand_path(@app_root + '/' +
                      @stack_dir) if @stack_dir.match(/^\.\.?\//)

    # default values
    @verbose = @config['verbose'] || 1
    @verbose = @verbose.to_i

    @config['tpl_ext'] ||= '.erb'
    raise ArgumentError, 'ERROR: `include` key depriciated, ' +
          'please update your yml file' if @config['include']
    @config['include'] = []
    @config['exclude'] ||= []
    @config['export'] ||= [] # even export can be blank
    @config['stack'] ||= []
    @config['files'] ||= {}

    # attrs to assigned into template
    @attrs = {}
    # file list under the app_root
    @self_files = []

    @files = @config['files']
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

      @self_files << f unless @self_files.include?(f)
    end
  end

  # render file in app-root
  def render_self!(files)
    files.each do |f|
      if File.exists?(f + @config['tpl_ext'])
        basename = f.sub(/^#{@app_root}\//, '')
        carp "From #{'self'.blue.bold} render #{basename.bold}",
             render_file!(f + @config['tpl_ext'], f), 1
      end
    end
  end

  # copy from a stack of applications
  def merge_stacks!(stack)
    stack.each do |app|
      app_dir, groups = '', ['default']
      if app.is_a?(Hash)
        app.each { |k, v| app, groups = k, v }
      end
      app_dir = @stack_dir + '/' + app

      raise "no directory found for #{app}" unless File.directory?(app_dir)
      raise "no configuration found for #{app}" unless
               File.exists?(app_dir + '/' + File.basename(@conf_file))

      # loop over remote files
      elist = export_list(app_dir, groups)
      elist.each do |file|
        # skip .erb file as template
        next if file.match(/#{@config['tpl_ext']}$/) &&
                elist.include?(file.sub(/#{@config['tpl_ext']}$/, ''))
        # find the absolute path for source and target file for copy
        src_f = File.expand_path(app_dir + '/' + file)
        tgt_f = File.expand_path(@app_root + '/' + file)

        if @files[file] == '__self' # don't handle it
          carp "From #{app.blue.bold} #{file.bold}",
               'skip, use '.white + @files[file], 2
        else # not registered as self, copy over
          unless @files[file] == app
            carp "By #{app.bold.blue}, overwrite #{@files[file].bold} #{file}",
                 'ok'.green, 1 if @files[file]
            @files[file] = app
          end

          if File.exists?(src_f + @config['tpl_ext'])
            carp "From #{app.blue.bold} render #{file.bold}",
                 render_file!(src_f + @config['tpl_ext'], tgt_f), 1

          else
            carp "From #{app.blue.bold} copy #{file.bold}",
                 copy_file!(src_f, tgt_f), 1
          end

          # register the copied file to app-root file list
          @self_files << file unless @self_files.include?(file)
        end
      end
    end
  end

  # print debug / information message to console based on verbose level
  def carp(job, state = 'done'.green, v = 1)
    return if @verbose < v
    dots = 70 - job.size
    job += ' ' + '.' * dots if dots > 0
    puts job + ' ' + state
  end

  # fetch (and cache) git ignore file lists for a specific directory
  def gitignore_list(dir)
    @gitignore_list ||= {}
    @gitignore_list[dir] ||= []

    ilist = []
    if File.exists?(dir + '/.gitignore')
      File.read(dir + '/.gitignore').split("\n").each do |line|
        Dir[dir + '/' + line].each do |f|
          fn = f.sub(/^#{dir}\//, '')
          ilist << fn unless ilist.include?(fn)
        end
      end
    end
    @gitignore_list[dir] = ilist
  end

  # if f1 newer than f2, or f2 not exits but f1 does.
  def newer?(f1, f2)
    return false unless File.exists?(f1)
    return true unless File.exists?(f2)
    File.mtime(f1) > File.mtime(f2)
  end

  # find a list of file to copy based on export setting
  def export_list(dir, groups = ['default'])
    dir_conf = YAML.load(File.read(dir + '/' + File.basename(@conf_file)))
    dir_conf['export'] ||= []
    dir_conf['exclude'] ||= []

    # update attr list for assign to template files
    @attrs.deep_merge! dir_conf['attrs'] if dir_conf['attrs'] &&
                                           dir_conf['attrs'].is_a?(Hash)

    group_patterns, flist = { 'default' => [] }, []
    # export list defined in stack app's configuration
    dir_conf['export'].each do |e|
      if e.is_a?(Hash)
        e.each { |k, v| group_patterns[k] = v }
      else
        group_patterns['default'] << e
      end
    end

    group_patterns.each do |k, v|
      raise "file for group #{k} is not a array." unless v.is_a?(Array)
      next unless groups.include?(k) || groups.include?('all')
      v.each do |e|
        Dir[dir + '/' + e].each do |f|
         fn = f.sub(/^#{dir}\/?/, '')
         flist << fn unless flist.include?(fn)
        end
      end
    end

    exc_list = []
    dir_conf['exclude'].each do |exc|
      Dir[dir + '/' + exc].each do |f|
        fn = f.sub(/^#{dir}\/?/, '')
        exc_list << fn unless exc_list.include?(fn)
      end
    end

    # adjust by include/exclude and
    flist - gitignore_list(dir) - exc_list
  end

  # copy file if newer
  def copy_file!(f, target)
    # directory?
    if File.directory?(f)
      if File.directory?(target)
        done = 'exists'.green
      else
        FileUtils.mkdir_p target
        done = 'created'.bold.green
      end
    else
      if newer?(f, target)
        target_dir = File.dirname(target)
        FileUtils.mkdir_p target_dir unless File.directory?(target_dir)
        FileUtils.copy f, target
        done = 'copied'.bold.green
      else
        done = 'keep'.white
      end
    end
    done
  end

  # render from erb if newer
  def render_file!(f, target)
    done = 'keep'.white
    # unless newer?(target, f)
    tilt = Tilt::ERBTemplate.new(f)
    oh = File.open(target, 'wb')
    oh.write tilt.render(OpenStruct.new(@attrs.deep_merge(@config['attrs'])))
    oh.close

    # update template timestamp
    FileUtils.touch(f)
    done = 'rendered'.bold.green
    # end
    # done
  end

  # use module variables, skip `new`
  # rubocop:disable ModuleFunction
  extend self
end
