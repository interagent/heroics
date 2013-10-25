module Heroics
  # Sanitize a name to make it suitable for use as a Ruby method name.
  #
  # @param name [String] The name to sanitize.
  # @return [String] The new name with capitals converted to lowercase, and
  #   dashes and spaces converted to underscores.
  def self.sanitize_name(name)
    name.downcase.gsub(/[- ]/, '_')
  end
end
