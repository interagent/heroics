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
      name = parameters.shift
      if name.nil? || name == 'help'
        usage
      else
        command = @commands[name]
        if command.nil?
          @output.write("There is no command called '#{name}'.")
        else
          command.run(*parameters)
        end
      end
    end

    private

    # Write usage information to the output stream.
    def usage
      if @commands.empty?
        @output.write 'No commands are available.'
        return
      end

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
    schema['definitions'].each do |resource_name, resource_schema|
      resource_schema['links'].each do |link_schema|
        path = link_schema['href']
        title = Heroics::sanitize_name(link_schema['title'])
        command_name = "#{resource_name}:#{title}"
        properties = resource_schema['definitions']
        commands[command_name] = Command.new(name, resource_name, link_schema,
                                             properties, client, output)
      end
    end
    Heroics::CLI.new(name, commands, output)
  end

  def self.cli_from_schema_url(name, output, url, options={})
    schema = download_schema(url, options)
    cli_from_schema(name, output, schema, url, options)
  end
end
