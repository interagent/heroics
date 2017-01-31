# frozen_string_literal: true

module Heroics
  # Attempts to load configuration, provides defaults, and provide helpers to access that data
  class Configuration
    def self.defaults
      @defaults ||= Configuration.new
    end

    def initialize
      yield self if block_given?
    end
  end
end
