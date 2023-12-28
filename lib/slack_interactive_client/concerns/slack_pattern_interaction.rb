# frozen_string_literal: true
require 'active_support'

module SlackPatternInteraction
  def method_missing(method_name, *arguments, &block)
    if @extracted_values.has_key?(method_name.to_s)
      @extracted_values[method_name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @extracted_values.has_key?(method_name.to_s) || super
  end

  private

  def extract_values(string)
    return {} if string.blank?
    # Find all dynamic parts of the pattern
    dynamic_parts = @pattern.scan(/\$\[(.*?)\]/).flatten

    # Create a regex pattern replacing dynamic parts with capture groups
    regex_pattern = @pattern.gsub(/\$\[.*?\]/, '(\w+)')
    regex = Regexp.new(regex_pattern)

    # Match the string with the regex
    match = string.match(regex)

    return unless match

    # Iterate over each capture and store in the hash
    dynamic_parts.each_with_index do |variable_name, index|
      @extracted_values[variable_name] = match[index + 1]
    end
  end
end
