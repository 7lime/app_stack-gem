# encoding: utf-8
require 'spec_helper'
require 'fileutils'

describe AppStack do
  describe '#newer?' do
    it 'true for newer file' do
      FileUtils.touch('.rspec_new')
      AppStack.newer?('.rspec_new', '.rspec').should be_true
      FileUtils.rm('.rspec_new')
    end

    it 'handles non exits file well' do
      AppStack.newer?('.rspec', '.rspec_non').should be_true
      AppStack.newer?('.no_rspec', '.rspec').should be_false
    end
  end

  describe '#export_list' do
    subject :el do
      AppStack.load_configuration('spec/fixtures/incexc-config.yml')
      AppStack.export_list('spec/fixtures/incexc')
    end

    it 'contains exported files' do
      el.include?('lib/anyway.rb').should be_true
      el.include?('lib/mixin/otherlib.rb').should be_true
    end

    it 'excludes gitignore files' do
      el.include?('lib/mixin/otherlist.rb.bak').should be_false
    end

    it 'excludes explicitly excluded files' do
      el.include?('lib/extra/excludes.rb').should be_false
    end

    it 'include explicitly included files' do
      el.include?('spec/spec_helper.rb').should be_true
      el.include?('spec/support/api_test.rb').should be_true
    end
  end

  describe '#merge_stacks!' do
    it 'raise for non existing directory' do
      AppStack.load_configuration('spec/fixtures/sample_config.yml')
      stacks = AppStack.config['stack']
      expect { AppStack.merge_stacks!(stacks) }.to raise_error
    end
  end
end
