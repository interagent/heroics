module Heroics
  # A representation of an HTTP API that exposes methods that map to resources
  # defined in the schema.
  class HTTPClient
    # Instantiate an HTTP client.
    #
    # @param resources [Hash<String,Resource>] A hash that maps method names
    #   to resources.
    def initialize(resources)
      @resources = resources
    end

    # Find the resource the endpoint matching the specified name.
    #
    # @param name [String] The name of the resource to find.
    # @raise [NoMethodError] Raised if the name doesn't match a known resource.
    # @return [Resource] The resource matching the name.
    def method_missing(name)
      resource = @resources[name.to_s]
      if resource.nil?
        address = "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
        raise NoMethodError.new("undefined method `#{name}' for ##{address}")
      end
      resource
    end
  end
end
