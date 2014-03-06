module Heroics
  # An HTTP client with methods mapped to API resources.
  class Client
    # Instantiate an HTTP client.
    #
    # @param resources [Hash<String,Resource>] A hash that maps method names
    #   to resources.
    def initialize(resources)
      @resources = resources
    end

    # Find a resource.
    #
    # @param name [String] The name of the resource to find.
    # @raise [NoMethodError] Raised if the name doesn't match a known resource.
    # @return [Resource] The resource matching the name.
    def method_missing(name)
      name = name.to_s.gsub('_', '-')
      resource = @resources[name]
      if resource.nil?
        # TODO(jkakar) Do we care about resource names in the schema specified
        # with underscores?  If so, we should check to make sure the name
        # mangling we did above was actually a bad idea.
        address = "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
        raise NoMethodError.new("undefined method `#{name}' for ##{address}")
      end
      resource
    end
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
    Client.new(resources)
  end
end
