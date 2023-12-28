require 'spec_helper'

RSpec.describe SlackInteractiveClient::Bot do
  let(:message) { described_class.new }

  class HelloWorldInteraction; end

  describe '#define' do
    before do
      described_class.define do
        interaction :hello_world, HelloWorldInteraction
      end
    end

    it 'stores the interactions' do
      expect(described_class.interactions.size).to eq(1)
      expect(described_class.interactions[:hello_world]).to eq(HelloWorldInteraction)
    end
  end
end
