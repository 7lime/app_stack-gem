$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'app_stack/version'

Gem::Specification.new 'app_stack', AppStack::VERSION do |s|
  s.description       = 'Merge app source code in a stack to increase module reusability'
  s.summary           = 'Use as a rake task, define a stack of modules and app-stack will merge files from those stack-apps to the local application directory.'
  s.authors           = ['Huang Wei']
  s.email             = 'huangw@7lime.com'
  s.homepage          = 'https://github.com/7lime/app_stack-gem'
  s.files             = `git ls-files`.split("\n") - %w[.gitignore Rakefile]
  s.license           = 'MIT'
  s.test_files        = Dir.glob('{spec,test}/**/*.rb')

  s.add_dependency 'tilt'
  s.add_dependency 'term-ansicolor'
  s.add_development_dependency 'rspec', '~> 2.5'
end

