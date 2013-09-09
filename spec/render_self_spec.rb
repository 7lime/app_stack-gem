# encoding: utf-8
require 'spec_helper'
require 'fileutils'

describe AppStack do
  describe '#render_self!' do
    it 'render using erb file in the app-root' do
      FileUtils.rm('spec/fixtures/my_app/config/self_render.conf')
      FileUtils.touch('spec/fixtures/my_app/config/self_render.conf')
      sleep 1
      FileUtils.touch('spec/fixtures/my_app/config/self_render.conf.erb')
      AppStack.stackup!('spec/fixtures/my_app/.app_stack.yml')
      cts = File.read('spec/fixtures/my_app/config/self_render.conf')
      cts.should match(/self config for my_app_code/)
    end
  end
end
