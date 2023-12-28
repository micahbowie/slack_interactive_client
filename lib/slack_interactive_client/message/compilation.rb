# frozen_string_literal: true

module SlackInteractiveClient
  class Message
    class Compilation
      attr_reader :payload, :csv_message, :csv_data
      def initialize(payload, csv_message = false, csv_data = {})
        @payload = payload
        @csv_message = csv_message
        @csv_data = csv_data
      end

      def blocks
        payload[:blocks]&.to_json
      end

      def channel
        if payload[:channel].is_a?(Array)
          payload[:channel].first
        elsif payload[:channel].is_a?(String)
          payload[:channel]
        end
      end

      alias csv? csv_message
    end
  end
end