# frozen_string_literal: true

module SlackWebhooks
  def slack_command
    return nil if params[:command].nil?

    params[:command].split('/')[1].downcase
  end
end