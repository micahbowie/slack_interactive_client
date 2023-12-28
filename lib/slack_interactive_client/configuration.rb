# frozen_string_literal: true

module SlackInteractiveClient
  class Configuration
    attr_accessor :auth_token, :redis_instance, :logger_instance, :base_controller_class, :signing_secret

    def initialize
      @base_controller_class = "ApplicationController"
    end
  end
end
