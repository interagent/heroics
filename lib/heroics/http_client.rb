module Heroics
  # A representation of an HTTP API that exposes methods that map to resources
  # defined in the schema.
  class HTTPClient
    # Instantiate a new HTTP client.
    #
    # @param url [String] The URL to use when making requests.  Include the
    #   username and password to use with HTTP basic auth.
    # @param schema [Hash] The schema to use with the client.  Keys must be
    #    strings.
    def initialize(url, schema)
      @url = url
      @resources = {}
      schema['definitions'].each do |name, resource_schema|
        name = sanitize_name(name)
        @resources[name] = Resource.new(resource_schema)
      end
    end

    def method_missing(method, *args)
    end
  end
end
