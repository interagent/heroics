module Heroics
  # Generate a static client that uses Heroics under the hood.  This is a good
  # option if you want to ship a gem or generate API documentation using Yard.
  def self.generate_client(module_name, schema, url, options)
    filename = File.dirname(__FILE__) + '/views/client.erb'
    eruby = Erubis::Eruby.new(File.read(filename))
    context = build_context(module_name, schema, url, options)
    eruby.evaluate(context)
  end

  private

  def self.build_context(module_name, schema, url, options)
    resources = []
    schema.resources.each do |resource_schema|
      links = []
      # puts
      # puts
      # puts "RESOURCE: #{resource_schema.name.gsub('-', '_')}"
      resource_schema.links.each do |link_schema|
        links << GeneratorLink.new(link_schema.name.gsub('-', '_'),
                                   link_schema.description,
                                   link_schema.parameter_details,
                                   link_schema.needs_request_body?)
        # puts link_schema.parameter_details
      end
      resources << GeneratorResource.new(resource_schema.name.gsub('-', '_'),
                                         resource_schema.description,
                                         links)
    end

    context = {module_name: module_name,
               url: url,
               default_headers: options.fetch(:default_headers, {}),
               cache: options.fetch(:cache, {}),
               description: schema.description,
               schema: MultiJson.encode(schema.schema),
               resources: resources}
  end

  class GeneratorResource
    attr_reader :name, :description, :links

    def initialize(name, description, links)
      @name = name
      @description = description
      @links = links
    end

    def class_name
      Heroics.camel_case(name)
    end
  end

  class GeneratorLink
    attr_reader :name, :description, :parameters, :takes_body

    def initialize(name, description, parameters, takes_body)
      @name = name
      @description = description
      @parameters = parameters
      if takes_body
        parameters << BodyParameter.new
      end
    end

    def parameter_names
      @parameters.map { |info| info.name }.join(', ')
    end
  end

  def self.camel_case(text)
    return text if text !~ /_/ && text =~ /[A-Z]+.*/
    text = text.split('_').map{ |element| element.capitalize }.join
    [/^Ssl/, /^Http/, /^Xml/].each do |replace|
      text.sub!(replace) { |match| match.upcase }
    end
    text
  end

  class BodyParameter
    attr_reader :name, :description

    def initialize
      @name = 'body'
      @description = 'the object to pass as the request payload'
    end
  end
end
