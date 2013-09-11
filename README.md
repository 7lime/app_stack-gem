# Merge Source Code from Directories in Chain

## Concept

Build your application by copy source files from
a stack of modules.

## Synposis

Put a configuration file `.app_stack.yml` in your application
directory, in format like:

    stack: 
      - module-1
      - module-2: [defaults, tests]
    stack_dir: '../stack-apps'
    tpl_ext: '.erb'
    verbose: 1
    export:
      - lib/**/*.rb
      - app/**/*.rb
      - tests:
          - spec/**/*.rb
    exclude:
      - lib/extra/*.rb
    attrs:
      application_name: App Name
      application_code: app_code
      database_password: the very secret
      gems:
        default:
          - rspec: '~> 2.0.0'
          - ...
        development:
    files:
      README.md: __self
 

`stack`
: 设置导入的模块名，元素为字符串（只导入'default'组的文件）或Hash，
: 为Hash时，key为模块名，值为文件组的数组（'all'代表全部）。

`stack_dir`（默认为`../stack-apps`）
: 模块程序所在位置。

`export`（默认为空）
: 可被拷贝至其他模块的文件pattern（为字符串时），或pattern的组
: （像上述示例中的`tests`一样）。

`exclude`（默认为空）
: 导出到其它模块时，从`export`列表中除外的文件pattern。
: 注意如果模块中定义了`.gitignore`文件，则其中的内容也会被加载至
: `exclude`列表。

`attrs`
: 用于assign至`.erb`文件的属性值。在上面的例子中module2会继承
: module1中设置的值。

`files` field is auto-generated, you should not edit it manually.

`export` defines files that should be copied when other modules include
the current module. Besides `export`, the acquire module can use `include`
and `exclude` adjust files that imports from other modules.

Variables defined in `attrs` will be assigned into `.erb` files.

`gems` need a support from `Gemfile.erb`.

## Templates

If you have both a `config.yml` and a `config.yml.erb` file, when export,
the `config.yml.erb` will be used instead of `config.yml`, and `attrs` will
be assigned into this file. 

Variables in `attrs` will be merged in chain follows the app-stack.

