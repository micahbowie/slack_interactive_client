# frozen_string_literal: true

#  EXAMPLE
# 
# SlackInteractiveClient::Bot.define do
#   interaction :hello_world, HelloWorldInteraction
# end
#
require 'active_support'

module SlackInteractiveClient
  class Bot
    class << self
      attr_reader :interactions

      def define(&block)
        @interactions ||= HashWithIndifferentAccess.new
        instance_exec(&block)
      end

      def interaction(name, interaction_class)
        @interactions[name] = interaction_class
      end
    end
  end
end
