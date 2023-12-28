# frozen_string_literal: true

require_relative "../base_interaction"

module SlackInteractiveClient
  class UnknownCommandInteraction < BaseInteraction
    interaction_options can_interact: :all, channels: :all

    def execute
      response = "Hmmm. I don't know that command. If you think I should double check your slack configuration and your interaction definitions"
      send_message(response)
    end
  end
end
