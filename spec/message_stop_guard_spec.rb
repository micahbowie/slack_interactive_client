require 'spec_helper'

RSpec.describe SlackInteractiveClient::MessageStopGuard do
  let(:interaction_params) { { text: "to micah the state TEXAS"} }
  let(:interaction_class) { TestInteraction.new(interaction_params) }

  describe '#scrubber' do
    it 'filters out the value' do
      scrubbed = described_class.scrubber.call(%(ssn: 1234))

      expect(scrubbed).to include("[FILTERED]")
      expect(scrubbed).not_to include("1234")
    end
  end
end
