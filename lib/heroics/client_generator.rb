module Heroics
  # Generate a static client that uses Heroics under the hood.  This is a good
  # option if you want to ship a gem or generate API documentation using Yard.
  def self.generate_client(module_name, schema)
    filename = File.dirname(__FILE__) + '/views/client.erb'
    eruby = Erubis::Eruby.new(File.read(filename))
    context = build_context(module_name, schema)
    eruby.evaluate(context)
  end

  private

  def self.build_context(module_name, schema)
    resources = []
    schema.resources.each do |resource_schema|
      links = []
      resource_schema.links.each do |link_schema|
        links << GeneratorLink.new(link_schema.name.gsub('-', '_'))
      end
      resources << GeneratorResource.new(resource_schema.name.gsub('-', '_'),
                                         links)
    end

    {module_name: module_name,
     schema: MultiJson.encode(schema.schema),
     resources: resources}
  end

  class GeneratorResource
    attr_reader :name, :links

    def initialize(name, links)
      @name = name
      @links = links
    end

    def class_name
      Heroics.camel_case(name)
    end
  end

  class GeneratorLink
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  def self.camel_case(text)
    return text if text !~ /_/ && text =~ /[A-Z]+.*/
    text = text.split('_').map{ |element| element.capitalize }.join
    text.sub(/^Ssl/, 'SSL')
  end
end
