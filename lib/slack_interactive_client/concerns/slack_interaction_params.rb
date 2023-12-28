# frozen_string_literal: true

require 'active_support'

module SlackInteractionParams
  DIRECT_MESSAGE_CHANNEL = "directmessage".freeze

  def slack_command
    interaction_params[:command]
  end

  def slack_user_name
    interaction_params[:user_name]
  end

  def slack_token
    interaction_params[:token]
  end

  def slack_team_id
    interaction_params[:team_id]
  end

  def slack_channel_id
    interaction_params[:channel_id]
  end

  def slack_message_text
    return nil unless interaction_params[:text].present? && interaction_params[:text].is_a?(String)

    interaction_params[:text].strip.squeeze
  end

  def slack_user_id
    interaction_params[:user_id]
  end

  def slack_response_url
    interaction_params[:response_url]
  end

  def slack_channel_name
    interaction_params[:channel_name]
  end

  def slack_team_domain
    interaction_params[:team_domain]
  end
end