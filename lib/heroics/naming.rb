# frozen_string_literal: true
module Heroics
  # Process a name to make it suitable for use as a Ruby method name.
  #
  # @param name [String] The name to process.
  # @return [String] The new name with capitals converted to lowercase, and
  #   dashes and spaces converted to underscores.
  def self.ruby_name(name)
    name.downcase.gsub(/[- ]/, '_')
  end

  # Process a name to make it suitable for use as a pretty command name.
  #
  # @param name [String] The name to process.
  # @return [String] The new name with capitals converted to lowercase, and
  #   underscores and spaces converted to dashes.
  def self.pretty_name(name)
    name.downcase.gsub(/[_ ]/, '-')
  end
end
