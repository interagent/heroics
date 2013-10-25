module Heroics
  # Raised when a schema has an error that prevents it from being parsed
  # correctly.
  class SchemaError < StandardError
  end

  # Create an HTTP client from a JSON schema.
  #
  # @param schema [Hash] The JSON schema to convert into an HTTP client.
  # @param url [String] The URL the generated client should use when making
  #   requests.  Include the username and password to use with HTTP basic
  #   auth.
  # @raises [SchemaError] Raised if the schema is malformed and can't be
  #   parsed correctly.
  # @return [HTTPClient] A client with resources and links from the JSON
  #   schema.
  def self.client_from_schema(schema, url)
    unless schema.has_key?('definitions')
      raise SchemaError.new("Missing top-level 'definitions' key.")
    end

    resources = {}
    schema['definitions'].each do |name, resource_schema|
      unless resource_schema.has_key?('links')
        raise SchemaError.new("'#{name}' resource is missing 'links' key.")
      end

      links = {}
      resource_schema['links'].each do |link_schema|
        path = link_schema['href']
        method = link_schema['method'].downcase.to_sym
        title = sanitize_name(link_schema['title'])
        links[title] = Link.new(url, path, method)
      end
      resources[name] = Resource.new(links)
    end
    HTTPClient.new(resources)
  end

  # Download a JSON schema and create an HTTP client with it.
  #
  # @param url [String] The URL for the schema.  The URL will be used by the
  #   generated client when it makes requests.
  # @param headers [Hash] Optionally, a list of headers to include in the
  #   request to download the schema.  Default is no headers.
  def self.client_from_schema_url(url, headers={})
    response = Excon.get(url, headers: headers, expects: [200, 201])
    schema = MultiJson.decode(response.body)
    client_from_schema(schema, URI::join(url, '/').to_s)
  end
end
