# Merge Source Code from Directories in Chain

## Concept

Build your application by copy source files from
a stack of modules.

## Synposis

Put a configuration file `.app_stack.yml` in your application
directory, in format like:

    stack: [module-1, module-2]
    stack_dir: '../stack-apps'
    tpl_ext: '.erb'
    verbose: 1
    export:
      lib/**/*.rb
      app/**/*.rb
    include:
      spec/**/*.rb
    exclude:
      lib/extra/*.rb
    attrs:
      application_name: App Name
      application_code: app_code
      database_password: the very secret
      gems:
        default:
          rspec: '~> 2.0.0'
          ...
        development:
    files:
      README.md << __self
 
`files` field is auto-generated, you should not edit it manually.

`export` defines files that should be copied when other modules include
the current module. Besides `export`, the acquire module can use `include`
and `exclude` adjust files that imports from other modules.

Variables defined in `attrs` will be assigned into `.erb` files.

## Templates

If you have both a `config.yml` and a `config.yml.erb` file, when export,
the `config.yml.erb` will be used instead of `config.yml`, and `attrs` will
be assigned into this file.

Variables in `attrs` will be merged in chain follows the app-stack.

