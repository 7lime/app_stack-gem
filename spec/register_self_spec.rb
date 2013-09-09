# encoding: utf-8
require 'spec_helper'

describe AppStack do
  describe '#register_self!' do
    it 'regist file in app root' do
      AppStack.load_configuration('spec/fixtures/sample_config.yml')
      AppStack.verbose = 0
      AppStack.register_self!('.')
      AppStack.files['.rspec'].should eq('__self')
    end
  end
end
