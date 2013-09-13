require 'spec_helper'

module AppStack
  def config
    @config
  end
end

describe AppStack do
  it 'load a app as a hash' do
    AppStack.load_configuration('spec/fixtures/app-sample.yml')
    AppStack.config['stack'][0].is_a?(Hash).should be_true
    # AppStack.stackup!('spec/fixtures/app-sample.yml')
  end
end
