# frozen_string_literal: true
module Heroics
  # An HTTP client with methods mapped to API resources.
  class Client
    # Instantiate an HTTP client.
    #
    # @param resources [Hash<String,Resource>] A hash that maps method names
    #   to resources.
    # @param url [String] The URL used by this client.
    def initialize(resources, url)
      # Transform resource keys via the ruby_name replacement semantics
      @resources = Hash[resources.map{ |k, v| [Heroics.ruby_name(k), v] }]
      @url = url
    end

    # Find a resource.
    #
    # @param name [String] The name of the resource to find.
    # @raise [NoMethodError] Raised if the name doesn't match a known resource.
    # @return [Resource] The resource matching the name.
    def method_missing(name)
      name = name.to_s
      resource = @resources[name]
      if resource.nil?
        # Find the name using the same ruby_name replacement semantics as when
        # we set up the @resources hash
        name = Heroics.ruby_name(name)
        resource = @resources[name]
        if resource.nil?
          raise NoMethodError.new("undefined method `#{name}' for #{to_s}")
        end
      end
      resource
    end

    # Get a simple human-readable representation of this client instance.
    def inspect
      url = URI.parse(@url)
      unless url.password.nil?
        url.password = 'REDACTED'
      end
      "#<Heroics::Client url=\"#{url.to_s}\">"
    end
    alias to_s inspect
  end

  # Create an HTTP client from a JSON schema.
  #
  # @param schema [Schema] The JSON schema to build an HTTP client for.
  # @param url [String] The URL the generated client should use when making
  #   requests.  Include the username and password to use with HTTP basic
  #   auth.
  # @param options [Hash] Configuration for links.  Possible keys include:
  #   - default_headers: Optionally, a set of headers to include in every
  #     request made by the client.  Default is no custom headers.
  #   - cache: Optionally, a Moneta-compatible cache to store ETags.  Default
  #     is no caching.
  # @return [Client] A client with resources and links from the JSON schema.
  def self.client_from_schema(schema, url, options={})
    resources = {}
    schema.resources.each do |resource_schema|
      links = {}
      resource_schema.links.each do |link_schema|
        links[link_schema.name] = Link.new(url, link_schema, options)
      end
      resources[resource_schema.name] = Resource.new(links)
    end
    Client.new(resources, url)
  end

  # Create an HTTP client with OAuth credentials from a JSON schema.
  #
  # @param oauth_token [String] The OAuth token to pass using the `Bearer`
  #   authorization mechanism.
  # @param schema [Schema] The JSON schema to build an HTTP client for.
  # @param url [String] The URL the generated client should use when making
  #   requests.
  # @param options [Hash] Configuration for links.  Possible keys include:
  #   - default_headers: Optionally, a set of headers to include in every
  #     request made by the client.  Default is no custom headers.
  #   - cache: Optionally, a Moneta-compatible cache to store ETags.  Default
  #     is no caching.
  # @return [Client] A client with resources and links from the JSON schema.
  def self.oauth_client_from_schema(oauth_token, schema, url, options={})
    authorization = "Bearer #{oauth_token}"
    # Don't mutate user-supplied data.
    options = Marshal.load(Marshal.dump(options))
    if !options.has_key?(:default_headers)
      options[:default_headers] = {}
    end
    options[:default_headers].merge!({"Authorization" => authorization})
    client_from_schema(schema, url, options)
  end

  # Create an HTTP client with Token credentials from a JSON schema.
  #
  # @param oauth_token [String] The token to pass using the `Bearer`
  #   authorization mechanism.
  # @param schema [Schema] The JSON schema to build an HTTP client for.
  # @param url [String] The URL the generated client should use when making
  #   requests.
  # @param options [Hash] Configuration for links.  Possible keys include:
  #   - default_headers: Optionally, a set of headers to include in every
  #     request made by the client.  Default is no custom headers.
  #   - cache: Optionally, a Moneta-compatible cache to store ETags.  Default
  #     is no caching.
  # @return [Client] A client with resources and links from the JSON schema.
  def self.token_client_from_schema(token, schema, url, options={})
    authorization = "Token token=#{token}"
    # Don't mutate user-supplied data.
    options = Marshal.load(Marshal.dump(options))
    if !options.has_key?(:default_headers)
      options[:default_headers] = {}
    end
    options[:default_headers].merge!({"Authorization" => authorization})
    client_from_schema(schema, url, options)
  end
end
