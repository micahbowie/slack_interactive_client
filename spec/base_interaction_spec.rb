require 'spec_helper'

RSpec.describe SlackInteractiveClient::BaseInteraction do
  class TestInteraction < ::SlackInteractiveClient::BaseInteraction
    interaction_pattern "to $[name] the state $[state_name]"

    def execute
      return "hey #{name} welcome to #{state_name}"
    end
  end
  let(:interaction_params) { { text: "to micah the state TEXAS"} }
  let(:interaction_class) { TestInteraction.new(interaction_params) }

  describe '#call' do
    it 'stores the interactions' do
      expect(interaction_class.call).to eq("hey micah welcome to TEXAS")
    end
  end
end
