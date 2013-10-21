module Heroics
  # A representation of a resource that exposes links as methods.
  class Resource
    # Instantiate a resource.
    #
    # @param methods [Hash<String,Link>] A hash that maps method names to
    #   links.
    def initialize(methods)
      @methods = methods
    end

    private

    # Make an HTTP request to the endpoint matching the specified link.
    #
    # @param name [String] The name of the method to invoke.
    # @param parameters [Array] The arguments to pass to the method.  This
    #   should always be a `Hash` mapping parameter names to values.
    # @raise [NoMethodError] Raised if the name doesn't match a known method.
    # @return [String,Array,Hash] The response received from the server.  JSON
    #   responses are automatically decoded into Ruby objects.
    def method_missing(name, *parameters)
      link = @methods[name.to_s]
      if link.nil?
        address = "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
        raise NoMethodError.new("undefined method `#{name}' for ##{address}")
      end
      link.run(*parameters)
    end
  end
end
