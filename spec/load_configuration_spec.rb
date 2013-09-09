# encoding: utf-8
require 'spec_helper'

describe AppStack do
  describe '#load_configuration' do
    it 'load yaml configurations' do
      AppStack.load_configuration('spec/fixtures/sample_config.yml')
      AppStack.config['tpl_ext'].should eq('.erb')
    end

    it 'set initial directories' do
      AppStack.app_root.should eq(File.expand_path('spec/fixtures'))
      AppStack.stack_dir.should eq(File.expand_path('spec/apps'))
    end
  end
end
