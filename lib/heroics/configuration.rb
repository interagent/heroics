# frozen_string_literal: true

module Heroics
  # Attempts to load configuration, provides defaults, and provide helpers to access that data
  class Configuration
    attr_reader :base_url,
      :cache_path,
      :module_name,
      :schema,
      :ruby_name_replacement_patterns,
      :options

    def self.defaults
      @defaults ||= Configuration.new
    end

    def self.restore_defaults
      @defaults = Configuration.new
    end

    def initialize
      @options = {}
      @options[:cache] = 'Moneta.new(:Memory)'
      @options[:default_headers] = {}

      @ruby_name_replacement_patterns = { /[\s-]+/ => '_' }

      yield self if block_given?
    end

    def schema=(schema)
      @schema = schema
    end

    def schema_filepath=(schema_filepath)
      @schema = Heroics::Schema.new(MultiJson.decode(open(schema_filepath).read))
    end

    def module_name=(module_name)
      @module_name = module_name
    end

    def base_url=(base_url)
      @base_url = base_url
    end

    def cache_path=(cache_path)
      @options[:cache] = "Moneta.new(:File, dir: \"#{cache_path}\")"
    end

    def headers=(headers)
      raise "Must provide a hash of headers" unless headers.is_a?(Hash)
      @options[:default_headers] = headers
    end

    def ruby_name_replacement_patterns=(patterns)
      raise "Must provide a hash of replacements" unless patterns.is_a?(Hash)
      @ruby_name_replacement_patterns = patterns
    end
  end
end
