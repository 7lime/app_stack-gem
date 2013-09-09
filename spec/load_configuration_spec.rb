require 'spec_helper'

# mixin-up, add stub-reader for testing
module AppStack
  attr_reader :config, :app_root, :stack_dir
end

describe AppStack do
  it 'loads configurations' do
    AppStack.load_configuration('spec/fixtures/sample_config.yml')
    AppStack.config['tpl_ext'].should eq('.erb')
    AppStack.app_root.should eq(File.expand_path('spec/fixtures'))
    AppStack.stack_dir.should eq(File.expand_path('spec/apps'))
  end
end
