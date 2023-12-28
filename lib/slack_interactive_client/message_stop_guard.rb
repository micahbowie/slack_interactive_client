# frozen_string_literal: true

module SlackInteractiveClient
  class MessageStopGuard
    FILTERED_SUBSTITUTION = '[FILTERED]'

    SENSITIVE_KEY_SUFFIXES = %w[
      number numbers ssn email date_of_birth secret token salt identity identity_fingerprint
    ].freeze

    # Builds a list of regex patterns for sensitive values
    def self.build_sensitive_value_patterns
      SENSITIVE_KEY_SUFFIXES.map do |key_suffix|
        /(?<key>#{key_suffix}[:\\'"=>\s]*)(?<value>[\w-]+)/i
      end
    end

    # Returns a lambda that scrubs sensitive information from a message
    def self.scrubber
      pii_patterns = build_sensitive_value_patterns

      lambda do |raw_msg|
        pii_patterns.reduce(raw_msg) do |msg, pii_regex|
          msg.gsub(pii_regex) { |m| $~[:key] + FILTERED_SUBSTITUTION }
        end
      end
    end
  end
end
