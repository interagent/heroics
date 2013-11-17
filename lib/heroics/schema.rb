module Heroics
  class Schema
    attr_reader :schema

    def initialize(schema)
      @schema = schema
      @resources = {}
      @schema['definitions'].each_key do |name|
        @resources[name] = ResourceSchema.new(@schema, name)
      end
    end

    def resource(name)
      if @schema['definitions'].has_key?(name)
        ResourceSchema.new(@schema, name)
      else
        raise SchemaError.new("Unknown resource '#{name}'.")
      end
    end

    def resources
      @resources.values
    end
  end

  class ResourceSchema
    attr_reader :name

    def initialize(schema, name)
      @schema = schema
      @name = name
      link_schema = schema['definitions'][name]['links']
      @links = Hash[link_schema.each_with_index.map do |link, link_index|
                      link_name = Heroics::sanitize_name(link['title'])
                      [link_name, LinkSchema.new(schema, name, link_index)]
                    end]
    end

    def link(name)
      schema = @links[name]
      raise SchemaError.new("Unknown link '#{name}'.") unless schema
      schema
    end

    def links
      @links.values
    end
  end

  class LinkSchema
    attr_reader :name, :resource_name, :description

    def initialize(schema, resource_name, link_index)
      @schema = schema
      @resource_name = resource_name
      @link_index = link_index
      @name = Heroics::sanitize_name(link_schema['title'])
      @description = link_schema['description']
    end

    def method
      link_schema['method'].downcase.to_sym
    end

    def parameters
      resolve_parameters(link_schema['href'].scan(PARAMETER_REGEX))
    end

    def body
      if body_schema = link_schema['schema']
        definitions = @schema['definitions'][@resource_name]['definitions']
        Hash[body_schema['properties'].keys.map do |property|
               [property, definitions[property]['example']]
             end]
      end
    end

    # Inject parameters into the link href and return the body, if it exists.
    #
    # @param parameters [Array] The list of parameters to inject into the
    #   path.
    # @raise [ArgumentError] Raised if either too many or too few parameters
    #   were provided.
    # @return [String,Object] A path and request body pair.  The body value is
    #   nil if a payload wasn't included in the list of parameters.
    def format_path(parameters)
      path = link_schema['href']
      parameter_size = path.scan(PARAMETER_REGEX).size
      too_few_parameters = parameter_size > parameters.size
      # FIXME We should use the schema to detect when a request body is
      # permitted and do the calculation correctly here. -jkakar
      too_many_parameters = parameter_size < (parameters.size - 1)
      if too_few_parameters || too_many_parameters
        raise ArgumentError.new("wrong number of arguments " +
                                "(#{parameters.size} for #{parameter_size})")
      end

      (0..parameter_size).each do |i|
        path = path.sub(PARAMETER_REGEX, format_parameter(parameters[i]))
      end
      body = parameters.slice(parameter_size)
      return path, body
    end

    private

    PARAMETER_REGEX = /\{\([%\/a-zA-Z0-9_]*\)\}/

    def link_schema
      @schema['definitions'][@resource_name]['links'][@link_index]
    end

    def resolve_parameters(parameters)
      # FIXME This is all pretty terrible.  It'd be much better to
      # automatically resolve $ref's based on the path instead of special
      # casing things all over the place here. -jkakar
      properties = @schema['definitions'][@resource_name]['properties']
      definitions = Hash[properties.each_pair.map do |key, value|
                           [value['$ref'], key]
                         end]
      parameters.map do |parameter|
        definition_name = URI.unescape(parameter[2..-3])
        if definitions.has_key?(definition_name)
          definitions[definition_name]
        else
          definition_name = definition_name.split('/')[-1]
          resource_definitions = @schema['definitions'][@resource_name]['definitions'][definition_name]
          if resource_definitions.has_key?('anyOf')
            resource_definitions['anyOf'].map do |property|
              definitions[property['$ref']]
            end.join('|')
          else
            resource_definitions['oneOf'].map do |property|
              definitions[property['$ref']]
            end.join('|')
          end
        end
      end
    end

    # Convert a path parameter to a format suitable for use in a path.
    #
    # @param [Fixnum,String,TrueClass,FalseClass,Time] The parameter to format.
    # @return [String] The formatted parameter.
    def format_parameter(parameter)
      parameter.instance_of?(Time) ? iso_format(parameter) : parameter.to_s
    end

    # Convert a time to an ISO 8601 combined data and time format.
    #
    # @param time [Time] The time to convert to ISO 8601 format.
    # @return [String] An ISO 8601 date in `YYYY-MM-DDTHH:MM:SSZ` format.
    def iso_format(time)
      time.getutc.strftime('%Y-%m-%dT%H:%M:%SZ')
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
