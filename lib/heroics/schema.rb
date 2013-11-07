module Heroics
  # Download a JSON schema from a URL.
  #
  # @param url [String] The URL for the schema.
  # @param options [Hash] Configuration for links.  Possible keys include:
  #   - default_headers: Optionally, a set of headers to include in every
  #     request made by the client.  Default is no custom headers.
  # @return [Hash] A hash representing the downloaded JSON schema.
  def self.download_schema(url, options={})
    default_headers = options.fetch(:default_headers, {})
    response = Excon.get(url, headers: default_headers, expects: [200, 201])
    MultiJson.decode(response.body)
  end
end
