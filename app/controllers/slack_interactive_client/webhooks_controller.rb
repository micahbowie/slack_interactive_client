# frozen_string_literal: true

require 'httparty'
require 'slack_interactive_client/slack_webhooks'

module SlackInteractiveClient
  class WebhooksController < ApplicationController
    include ::SlackWebhooks

    def create
      require_post_method

      interaction_class = ::SlackInteractiveClient::Bot.interactions[slack_command]
      if interaction_class.nil?
        ::SlackInteractiveClient::UnknownCommandInteraction.new(params).call
      else
        ::Object.const_get(interaction_class.to_s).new(params).call
      end
    end

    private

    def validate_slack_request
      signature = request.headers['X-Slack-Signature']

      OpenSSL::HMAC.hexdigest("SHA256", key, data)
    end

    def response_url
      params[:response_url]
    end

    def require_post_method
      head :unauthorized unless request.post?
    end
  end
end
