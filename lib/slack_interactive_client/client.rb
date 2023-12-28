# frozen_string_literal: true

require 'slack-ruby-client'
require_relative 'configuration'
require_relative 'message'
require_relative 'message_stop_guard'

module SlackInteractiveClient
  class Client
    class << self

      attr_writer :configuration

      def configuration
        @configuration ||= ::SlackInteractiveClient::Configuration.new
      end

      def reset
        @configuration = nil
      end

      def configure
        yield configuration
        ::Slack.configure do |config|
          config.token = configuration.auth_token
          config.logger = configuration.logger_instance
        end
        "SlackInteractiveClient::Client Configured!"
      end

      def send_message_with_template(template_name, args = {})
        compilation = ::SlackInteractiveClient::Message.compile(template_name, args)

        web_client.chat_postMessage(
          channel: compilation.channel,
          blocks: compilation.blocks,
          as_user: true,
        )

        if compilation.csv? && compilation.csv_data[:csv][:content]
          web_client.files_upload(
            channels: compilation.channel,
            content: compilation.csv_data[:csv][:content],
            title: compilation.csv_data[:csv][:title],
            filename: compilation.csv_data[:csv][:filename],
            initial_comment: compilation.csv_data[:csv][:comment],
            as_user: true,
          )
        end
        return "Message sent by: SlackInteractiveClient::Client"
      rescue ::Slack::Web::Api::Errors::SlackError => e
        puts "An error occurred when sending the message: #{e.message}"
      end

      def send_message(message, channel)
        scrubbed = ::SlackInteractiveClient::MessageStopGuard.scrubber.call(message)
        web_client.chat_postMessage(
          channel: channel,
          blocks: [{ type: 'rich_text', elements: [ type: 'rich_text_section', elements: [ { type: 'text', text: scrubbed } ] ] }],
          as_user: true,
        )
        return "Message sent by: SlackInteractiveClient::Client"
      rescue ::Slack::Web::Api::Errors::SlackError => e
        puts "An error occurred when sending the message: #{e.message}"
      end

      def send_csv(csv_data, channel)
        web_client.files_upload(
          channels: channel,
          content: csv_data[:content],
          title: csv_data[:title],
          filename: csv_data[:filename],
          initial_comment: csv_data[:comment],
          as_user: true,
        )
        return "Message sent by: SlackInteractiveClient::Client"
      rescue ::Slack::Web::Api::Errors::SlackError => e
        puts "An error occurred when sending the message: #{e.message}"
      end

      private

      def web_client
        ::Slack::Web::Client.new
      end
    end
  end
end
