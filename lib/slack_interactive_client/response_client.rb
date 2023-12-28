# frozen_string_literal: true

require 'httparty'

module SlackInteractiveClient
  class ResponseClient
    class << self
      # { "response_type": "in_channel", "response_type": "ephemeral" }
      # { "text": "text" }
      # { "blocks": [ ] }
      # { "replace_original": false" },
      def respond(response_url, body)
        ::HTTParty.post(response_url, 
                      body: body.to_json, 
                      headers: { 'Content-Type' => 'application/json' }
                    )
      end
    end
  end
end
