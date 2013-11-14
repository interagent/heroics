module Heroics
  class Schema
    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end

    def resource(name)
      if @schema['definitions'].has_key?(name)
        ResourceSchema.new(@schema, name)
      else
        raise SchemaError.new("Unknown resource '#{name}'.")
      end
    end
  end

  class ResourceSchema
    attr_reader :name

    def initialize(schema, name)
      @schema = schema
      @name = name
      link_schema = schema['definitions'][name]['links']
      @links = Hash[link_schema.each_with_index.map do |link, index|
                      link_name = Heroics::sanitize_name(link['title'])
                      [link_name, LinkSchema.new(schema, name, index)]
                    end]
    end

    def link(name)
      schema = @links[name]
      raise SchemaError.new("Unknown link '#{name}'.") unless schema
      schema
    end
  end

  class LinkSchema
    attr_reader :name, :resource_name, :description

    def initialize(schema, resource_name, index)
      @schema = schema
      @resource_name = resource_name
      @index = index
      link = schema['definitions'][resource_name]['links'][index]
      @name = Heroics::sanitize_name(link['title'])
      @description = link['description']
    end

    def parameters
    end

    private

    def link_schema
      @schema['definitions'][@resource_name]['links'][@index]
    end
  end

  # Download a JSON schema from a URL.
  #
  # @param url [String] The URL for the schema.
  # @param options [Hash] Configuration for links.  Possible keys include:
  #   - default_headers: Optionally, a set of headers to include in every
  #     request made by the client.  Default is no custom headers.
  # @return [Schema] The downloaded JSON schema.
  def self.download_schema(url, options={})
    default_headers = options.fetch(:default_headers, {})
    response = Excon.get(url, headers: default_headers, expects: [200, 201])
    Schema.new(MultiJson.decode(response.body))
  end
end
