# frozen_string_literal: true
module Heroics
  # A wrapper around a bare JSON schema to make it easier to use.
  class Schema
    attr_reader :schema

    # Instantiate a schema.
    #
    # @param schema [Hash] The bare JSON schema to wrap.
    def initialize(schema)
      @schema = schema
      @resources = {}
      @schema['properties'].each do |key, value|
        @resources[key] = ResourceSchema.new(@schema, key)
      end
    end

    # A description of the API.
    def description
      @schema['description']
    end

    # Get a schema for a named resource.
    #
    # @param name [String] The name of the resource.
    # @raise [SchemaError] Raised if an unknown resource name is provided.
    def resource(name)
      if @schema['definitions'].has_key?(name)
        ResourceSchema.new(@schema, name)
      else
        raise SchemaError.new("Unknown resource '#{name}'.")
      end
    end

    # The resource schema children that are part of this schema.
    #
    # @return [Array<ResourceSchema>] The resource schema children.
    def resources
      @resources.values
    end

    # Get a simple human-readable representation of this client instance.
    def inspect
      "#<Heroics::Schema description=\"#{@schema['description']}\">"
    end
    alias to_s inspect
  end

  # A wrapper around a bare resource element in a JSON schema to make it
  # easier to use.
  class ResourceSchema
    attr_reader :name

    # Instantiate a resource schema.
    #
    # @param schema [Hash] The bare JSON schema to wrap.
    # @param name [String] The name of the resource to identify in the schema.
    def initialize(schema, name)
      @schema = schema
      @name = name
      link_schema = schema['definitions'][name]['links'] || []

      duplicate_names = link_schema
        .group_by { |link| Heroics.ruby_name(link['title']) }
        .select { |k, v| v.size > 1 }
        .map(&:first)
      if !duplicate_names.empty?
        raise SchemaError.new("Duplicate '#{name}' link names: " +
                              "'#{duplicate_names.join("', '")}'.")
      end

      @links = Hash[link_schema.each_with_index.map do |link, link_index|
                      link_name = Heroics.ruby_name(link['title'])
                      [link_name, LinkSchema.new(schema, name, link_index)]
                    end]
    end

    # A description of the resource.
    def description
      @schema['definitions'][name]['description']
    end

    # Get a schema for a named link.
    #
    # @param name [String] The name of the link.
    # @raise [SchemaError] Raised if an unknown link name is provided.
    def link(name)
      schema = @links[name]
      raise SchemaError.new("Unknown link '#{name}'.") unless schema
      schema
    end

    # The link schema children that are part of this resource schema.
    #
    # @return [Array<LinkSchema>] The link schema children.
    def links
      @links.values
    end
  end

  # A wrapper around a bare link element for a resource in a JSON schema to
  # make it easier to use.
  class LinkSchema
    attr_reader :name, :resource_name, :description

    # Instantiate a link schema.
    #
    # @param schema [Hash] The bare JSON schema to wrap.
    # @param resource_name [String] The name of the resource to identify in
    #   the schema.
    # @param link_index [Fixnum] The index of the link in the resource schema.
    def initialize(schema, resource_name, link_index)
      @schema = schema
      @resource_name = resource_name
      @link_index = link_index
      @name = Heroics.ruby_name(link_schema['title'])
      @description = link_schema['description']
    end

    # Get the resource name in pretty form.
    #
    # @return [String] The pretty resource name.
    def pretty_resource_name
      Heroics.pretty_name(resource_name)
    end

    # Get the link name in pretty form.
    #
    # @return [String] The pretty link name.
    def pretty_name
      Heroics.pretty_name(name)
    end

    # Get the HTTP method for this link.
    #
    # @return [Symbol] The HTTP method.
    def method
      link_schema['method'].downcase.to_sym
    end

    # Get the Content-Type for this link.
    #
    # @return [String] The Content-Type value
    def content_type
      link_schema['encType'] || 'application/json'
    end

    def encode(body)
      case content_type
      when 'application/x-www-form-urlencoded'
        URI.encode_www_form(body)
      when /application\/.*json/
        MultiJson.dump(body)
      end
    end

    # Get the names of the parameters this link expects.
    #
    # @return [Array<String>] The parameters.
    def parameters
      parameter_names = link_schema['href'].scan(PARAMETER_REGEX)
      resolve_parameters(parameter_names)
    end

    # Get the names and descriptions of the parameters this link expects.
    #
    # @return [Hash<String, String>] A list of hashes with `name` and
    #   `description` key/value pairs describing parameters.
    def parameter_details
      parameter_names = link_schema['href'].scan(PARAMETER_REGEX)
      resolve_parameter_details(parameter_names)
    end

    def needs_request_body?
      return link_schema.has_key?('schema')
    end

    # Get an example request body.
    #
    # @return [Hash] A sample request body.
    def example_body
      if body_schema = link_schema['schema']
        definitions = @schema['definitions'][@resource_name]['definitions']
        Hash[body_schema['properties'].keys.map do |property|
          # FIXME This is wrong! -jkakar
          if definitions.has_key?(property)
            example = definitions[property]['example']
          else
            example = ''
          end
          [property, example]
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

      (0...parameter_size).each do |i|
        path = path.sub(PARAMETER_REGEX, format_parameter(parameters[i]))
      end
      body = parameters.slice(parameter_size)
      return path, body
    end

    private

    # Match parameters in definition strings.
    PARAMETER_REGEX = /\{\([%\/a-zA-Z0-9_-]*\)\}/

    # Get the raw link schema.
    #
    # @param [Hash] The raw link schema.
    def link_schema
      @schema['definitions'][@resource_name]['links'][@link_index]
    end

    # Get the names of the parameters this link expects.
    #
    # @param parameters [Array] The names of the parameter definitions to
    #   convert to parameter names.
    # @return [Array<String>] The parameters.
    def resolve_parameters(parameters)
      properties = @schema['definitions'][@resource_name]['properties']
      return [''] if properties.nil?
      definitions = Hash[properties.each_pair.map do |key, value|
                           [value['$ref'], key]
                         end]
      parameters.map do |parameter|
        definition_name = URI.unescape(parameter[2..-3])
        if definitions.has_key?(definition_name)
          definitions[definition_name]
        else
          definition_name = definition_name.split('/')[-1]
          resource_definitions = @schema[
            'definitions'][@resource_name]['definitions'][definition_name]
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

    # Get the parameters this link expects.
    #
    # @param parameters [Array] The names of the parameter definitions to
    #   convert to parameter names.
    # @return [Array<Parameter|ParameterChoice>] A list of parameter instances
    #   that represent parameters to be injected into the link URL.
    def resolve_parameter_details(parameters)
      parameters.map do |parameter|
        # URI decode parameters and strip the leading '{(' and trailing ')}'.
        parameter = URI.unescape(parameter[2..-3])

        # Split the path into components and discard the leading '#' that
        # represents the root of the schema.
        path = parameter.split('/')[1..-1]
        info = lookup_parameter(path, @schema)
        # The reference can be one of several values.
        resource_name = path[1].gsub('-', '_')
        if info.has_key?('anyOf')
          ParameterChoice.new(resource_name,
                              unpack_multiple_parameters(info['anyOf']))
        elsif info.has_key?('oneOf')
          ParameterChoice.new(resource_name,
                              unpack_multiple_parameters(info['oneOf']))
        else
          name = path[-1]
          Parameter.new(resource_name, name, info['description'])
        end
      end
    end

    # Unpack an 'anyOf' or 'oneOf' multi-parameter blob.
    #
    # @param parameters [Array<Hash>] An array of hashes containing '$ref'
    #   keys and definition values.
    # @return [Array<Parameter>] An array of parameters extracted from the
    #   blob.
    def unpack_multiple_parameters(parameters)
      parameters.map do |info|
        parameter = info['$ref']
        path = parameter.split('/')[1..-1]
        info = lookup_parameter(path, @schema)
        resource_name = path.size > 2 ? path[1].gsub('-', '_') : nil
        name = path[-1]
        Parameter.new(resource_name, name, info['description'])
      end
    end

    # Recursively walk the object hierarchy in the schema to resolve a given
    # path.  This is used to find property information related to definitions
    # in link hrefs.
    #
    # @param path [Array<String>] An array of paths to walk, such as
    #   ['definitions', 'resource', 'definitions', 'property'].
    # @param schema [Hash] The schema to walk.
    def lookup_parameter(path, schema)
      key = path[0]
      remaining = path[1..-1]
      if remaining.empty?
        return schema[key]
      else
        lookup_parameter(remaining, schema[key])
      end
    end

    # Convert a path parameter to a format suitable for use in a path.
    #
    # @param [Fixnum,String,TrueClass,FalseClass,Time] The parameter to format.
    # @return [String] The formatted parameter.
    def format_parameter(parameter)
      formatted_parameter = parameter.instance_of?(Time) ? iso_format(parameter) : parameter.to_s
      URI.escape formatted_parameter
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
    Schema.new(MultiJson.load(response.body))
  end

  # A representation of a parameter.
  class Parameter
    attr_reader :resource_name, :description

    def initialize(resource_name, name, description)
      @resource_name = Heroics.ruby_name(resource_name)
      @name = Heroics.ruby_name(name)
      @description = description
    end

    # The name of the parameter, with the resource included, suitable for use
    # in a function signature.
    def name
      [@resource_name, @name].compact.join("_")
    end

    # A pretty representation of this instance.
    def inspect
      "Parameter(name=#{@name}, description=#{@description})"
    end
  end

  # A representation of a set of parameters.
  class ParameterChoice
    attr_reader :resource_name, :parameters

    def initialize(resource_name, parameters)
      @resource_name = resource_name
      @parameters = parameters
    end

    # A name created by merging individual parameter descriptions, suitable
    # for use in a function signature.
    def name
      @parameters.map do |parameter|
        if parameter.resource_name
          parameter.name
        else
          "#{@resource_name}_#{parameter.name}"
        end
      end.join('_or_')
    end

    # A description created by merging individual parameter descriptions.
    def description
      @parameters.map { |parameter| parameter.description }.join(' or ')
    end

    # A pretty representation of this instance.
    def inspect
      "ParameterChoice(parameters=#{@parameters})"
    end
  end
end
