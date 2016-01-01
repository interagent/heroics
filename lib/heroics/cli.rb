# frozen_string_literal: true
module Heroics
  class CLI
    # Instantiate a CLI for an API described by a JSON schema.
    #
    # @param name [String] The name of the CLI.
    # @param schema [Schema] The JSON schema describing the API.
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
        if command_name = parameters.first
          command = @commands[command_name]
          command.usage
        else
          usage
        end
      else
        command = @commands[name]
        if command.nil?
          @output.write("There is no command called '#{name}'.\n")
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

  # Create a CLI from a JSON schema.
  #
  # @param name [String] The name of the CLI.
  # @param output [IO] The stream to write to.
  # @param schema [Hash] The JSON schema to use with the CLI.
  # @param url [String] The URL used by the generated CLI when it makes
  #   requests.
  # @param options [Hash] Configuration for links.  Possible keys include:
  #   - default_headers: Optionally, a set of headers to include in every
  #     request made by the CLI.  Default is no custom headers.
  #   - cache: Optionally, a Moneta-compatible cache to store ETags.  Default
  #     is no caching.
  # @return [CLI] A CLI with commands generated from the JSON schema.
  def self.cli_from_schema(name, output, schema, url, options={})
    client = client_from_schema(schema, url, options)
    commands = {}
    schema.resources.each do |resource_schema|
      resource_schema.links.each do |link_schema|
        command = Command.new(name, link_schema, client, output)
        commands[command.name] = command
      end
    end
    CLI.new(name, commands, output)
  end
end
