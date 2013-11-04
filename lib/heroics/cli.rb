module Heroics
  class CLI
    # Instantiate a CLI for an API described by a JSON schema.
    #
    # @param name [String] The name of the CLI.
    # @param schema [Hash] The JSON schema describing the API.
    # @param client [Client] A client generated from the JSON schema.
    # @param output [IO] The stream to write to.
    def initialize(name, commands, output)
      @name = name
      @commands = commands
      @output = output
    end

    # Run a command.
    #
    # @param parameters [Array] The parameters to use when running the
    #   command.  The first parameters is the name of the command and the
    #   remaining parameters are passed to it.
    def run(*parameters)
      command = parameters.shift
      if command.nil? || command == 'help'
        usage
      end
    end

    private

    def usage
      @output.write <<-USAGE
Usage: #{@name} <command> [<parameter> [...]] [<body>]

Help topics, type "#{@name} help <topic>" for more details:

USAGE

      name_width = @commands.keys.max_by { |key| key.size }.size
      @commands.sort.each do |name, command|
        name = name.ljust(name_width)
        description = command.description
        @output.puts("  #{name}    #{description}")
      end
    end
  end

  def self.cli_from_schema(name, output, schema, url, options={})
    client = client_from_schema(schema, url, options)
    commands = {}
    @schema['definitions'].each do |name, resource_schema|
      resource_schema['links'].each do |link_schema|
        path = link_schema['href']
        title = Heroics::sanitize_name(link_schema['title'])
        command_name = "#{name}:#{title}"
        commands[command_name] = Command.new()

        links << {name: link_name, description: link_schema['description']}
      end
    end
  end

  def self.cli_from_schema_url(name, output, url, options={})
    schema = download_schema(url, options)
    client = client_from_schema(schema, options)
    CLI.new(name, schema, client, output)
  end
end
