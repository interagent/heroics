# frozen_string_literal: true
module Heroics
  # Generate a static client that uses Heroics under the hood.  This is a good
  # option if you want to ship a gem or generate API documentation using Yard.
  def self.generate_client
    filename = File.dirname(__FILE__) + '/views/client.erb'
    eruby = Erubis::Eruby.new(File.read(filename))
    context = build_context(Heroics::Configuration.defaults.module_name,
      Heroics::Configuration.defaults.schema,
      Heroics::Configuration.defaults.base_url,
      Heroics::Configuration.defaults.options)
    eruby.evaluate(context)
  end

  private

  # Process the schema to build up the context needed to render the source
  # template.
  def self.build_context(module_name, schema, base_url, options)
    resources = []
    schema.resources.each do |resource_schema|
      links = []
      resource_schema.links.each do |link_schema|
        links << GeneratorLink.new(link_schema.name,
                                   link_schema.description,
                                   link_schema.parameter_details,
                                   link_schema.needs_request_body?)
      end
      resources << GeneratorResource.new(resource_schema.name,
                                         resource_schema.description,
                                         links)
    end

    {
      module_name: module_name,
      url: base_url,
      default_headers: options.fetch(:default_headers, {}),
      cache: options.fetch(:cache, {}),
      description: schema.description,
      schema: MultiJson.dump(schema.schema, pretty:true),
      resources: resources
    }
  end

  # A representation of a resource for use when generating source code in the
  # template.
  class GeneratorResource
    attr_reader :name, :description, :links

    def initialize(name, description, links)
      @name = Heroics.ruby_name(name)
      @description = description
      @links = links
    end

    # The name of the resource class in generated code.
    def class_name
      Heroics.camel_case(name)
    end
  end

  # A representation of a link for use when generating source code in the
  # template.
  class GeneratorLink
    attr_reader :name, :description, :parameters, :takes_body

    def initialize(name, description, parameters, takes_body)
      @name = Heroics.ruby_name(name)
      @description = description
      @parameters = parameters
      if takes_body
        parameters << BodyParameter.new
      end
    end

    # list of parameters for method signature, body is optional
    def method_signature
      @parameters.map { |info| info.name == 'body' ? "body = {}" : Heroics.ruby_name(info.name) }.join(', ')
    end

    # list of parameters to pass along from method signature to client calls
    def parameter_names
      @parameters.map { |info| Heroics.ruby_name(info.name) }.join(', ')
    end
  end

  # Convert a lower_case_name to CamelCase.
  def self.camel_case(text)
    return text if text !~ /_/ && text =~ /[A-Z]+.*/
    text = text.split('_').map{ |element| element.capitalize }.join
    [/^Ssl/, /^Http/, /^Xml/].each do |replace|
      text.sub!(replace) { |match| match.upcase }
    end
    text
  end

  # A representation of a body parameter.
  class BodyParameter
    attr_reader :name, :description

    def initialize
      @name = 'body'
      @description = 'the object to pass as the request payload'
    end
  end
end
