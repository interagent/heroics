module Heroics
  class HTTPClient
    # Instantiate a new HTTP client.
    #
    # @param url [String] The URL to use when making requests.  Include the
    #   username and password to use with HTTP basic auth.
    # @param schema [Hash] The schema to use with the client.  Keys must be
    #    strings.
    def initialize(url, schema)
      @url = url
      create_methods(schema)
    end

    private

    def create_methods(schema)
      schema['definitions'].each do |key, value|
      end
    end
  end
end
