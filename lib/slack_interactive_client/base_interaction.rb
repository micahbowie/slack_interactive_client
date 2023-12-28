# frozen_string_literal: true

require 'active_support/all'
require 'csv'
require_relative 'concerns/slack_interaction_params'
require_relative 'concerns/slack_pattern_interaction'

module SlackInteractiveClient
  class BaseInteraction
    include ::SlackInteractionParams
    include ::SlackPatternInteraction

    class << self
      attr_reader :interaction_config, :interaction_channels, :pattern_string

      # EXAMPLE
      #
      # interaction_options can_interact: { only: ['micah.bowie'] }, channels: []
      def interaction_options(options = {})
        set_interaction_config(options[:can_interact])
        @interaction_channels = options[:channels].empty? ? :all : options[:channels]
      end

      def interaction_pattern(pattern_string = '')
        @pattern_string = pattern_string.strip.squeeze
      end

      private

      def set_interaction_config(options)
        @interaction_config ||= { all: [], only: [], except: [] }
        return unless options.present?

        if options == :all
          @interaction_config[:all] << :all
          return
        end

        if options[:only] && options.is_a?(Hash)
          @interaction_config[:only] += Array(options[:only])
        end

        if options[:except] && options.is_a?(Hash)
          @interaction_config[:except] += Array(options[:except])
        end
      end
    end

    attr_reader :interaction_params
    def initialize(webhook_params = {})
      @interaction_params = webhook_params
      @pattern = self.class.pattern_string
      @extracted_values = {}
      extract_values(slack_message_text)
    end

    def call
      unless can_interact?
        send_message('You are not authorized to interact with this command or interaction is in an invalid channel.')
        return
      end
      execute
    end

    def execute
      puts "Method not reimplemented by child"
    end

    private

    def direct_message?
      slack_channel_name == ::SlackInteractionParams::DIRECT_MESSAGE_CHANNEL
    end

    def can_user_interact?
      # If not configuration is set then we allow any user to interact
      return true if self.class.interaction_config.nil?

      all_conditions = self.class.interaction_config[:all]
      only_conditions = self.class.interaction_config[:only]
      except_conditions = self.class.interaction_config[:except]

      return true if all_conditions.empty? && only_conditions.empty? && except_conditions.empty?
      return true if all_conditions.include?(:all)
      return true if only_conditions.include?(slack_user_name)
      return false if except_conditions.include?(slack_user_name)

      false
    end

    def interactive_channel?
      # If not configuration is set then we allow any user to interact
      return true if self.class.interaction_channels.nil?

      interaction_channels = self.class.interaction_channels

      return true if interaction_channels == :all
      return true if interaction_channels == :direct_message && direct_message?
      return false if interaction_channels == :direct_message && !direct_message?
      return false unless interaction_channels.is_a?(Array)
      return true if direct_message? && interaction_channels.include?(:direct_message)
      return true if interaction_channels.include?(slack_channel_name)

      false
    end

    def can_interact?
      can_user_interact? && interactive_channel?
    end

    def send_message(message)
      ::SlackInteractiveClient::Client.send_message(message, slack_channel_id)
    end

    def send_csv(csv_data)
      csv_content ||= CSV.generate do |csv|
        csv << csv_data.dig(:headers)
        csv_data.dig(:rows).each { |row| csv << row }
      end
      csv_data[:content] = csv_content

      ::SlackInteractiveClient::Client.send_csv(csv_data, slack_channel_id)
    end

    def send_message_with_template(template, args)
      ::SlackInteractiveClient::Client.send_message_with_template(template, args.merge(channel: slack_channel_id))
    end
  end
end
