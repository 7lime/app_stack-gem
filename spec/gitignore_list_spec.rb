# encoding: utf-8
require 'spec_helper'
require 'fileutils'

describe AppStack do
  describe '#gitignore_list' do
    context 'without .gitignore file' do
      it 'ignores nothing' do
        AppStack.gitignore_list('/spec/fixtures').size.should eq(0)
      end
    end

    context 'current directory' do
      it 'ignores .bak file' do
        FileUtils.touch('file.bak')
        AppStack.gitignore_list('.').include?('file.bak').should be_true
        FileUtils.rm('file.bak')
      end
    end
  end
end
