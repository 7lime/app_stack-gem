# encoding: utf-8

describe AppStack do
  describe '#stackup' do
    before(:all) do
      FileUtils.cp 'spec/fixtures/.app_stack.yml', 'spec/fixtures/my_app'

      %w[config/self_render.conf Gemfile].each do |f|
        FileUtils.touch('spec/fixtures/my_app/' + f)
      end

      sleep 1

      FileUtils.touch('spec/fixtures/my_app/config/self_render.conf.erb')
      FileUtils.touch('spec/fixtures/stack_apps/module-2/Gemfile.erb')

      # run the stackup script
      AppStack.stackup!('spec/fixtures/my_app/.app_stack.yml')
      AppStack.verbose = 2
    end

    it 'cp files from the chain of stacks' do
      c1 = File.read('spec/fixtures/my_app/lib/libonly1.rb')
      c2 = File.read('spec/fixtures/my_app/lib/libonly2.rb')
      c1.should match(/'libonlyl from module 1'/)
      c2.should match(/'libonly2 from module 2'/)
    end

    it 'copy the file found first' do
      cts = File.read('spec/fixtures/my_app/lib/auth_util.rb')
      cts.should match(/'auth_util from module 1'/)
    end

    it 'renders erb file from stack' do
      cts = File.read('spec/fixtures/my_app/Gemfile')
      cts.should match(/ruby\.taobao\.com/)
      cts.should match(/gem: 'rspec', '~> 2.0.0'/)
      cts.should match(/gem: 'mongoid'/)
      cts.should match(/gem: 'grape'/)
    end

    it 'renders erb file in app-root' do
      cts = File.read('spec/fixtures/my_app/config/self_render.conf')
      cts.should match(/self config for my_app_code/)
    end

    after(:all) do
      %w[config/self_render.conf Gemfile
         lib/libonly1.rb lib/libonly2.rb].each do |f|
        file = 'spec/fixtures/my_app/' + f
        FileUtils.rm(file) if File.exists?(file)
      end
    end
  end
end
