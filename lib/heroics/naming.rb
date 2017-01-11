# frozen_string_literal: true
module Heroics
  # Process a name to make it suitable for use as a Ruby method name.
  #
  # @param name [String] The name to process.
  # @return [String] The new name with capitals converted to lowercase,
  #   dashes and spaces converted to underscores, and non-identifier 
  #   characters removed.
  # @raise [SchemaError] Raised if the name contains invalid characters.
  def self.ruby_name(name)
    ruby_name = name.downcase.gsub(/[- ]/, '_')
    raise SchemaError.new("Name '#{name}' converts to invalid Ruby name '#{ruby_name}'.") if ruby_name =~ /\W/
    ruby_name
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
