module Heroics
  class Command
    # Instantiate a command.
    #
    # @param cli_name [String] The name of the CLI.
    # @param schema [LinkSchema] The schema for the underlying link this
    #   command represents.
    # @param client [Client] The client to use when making requests.
    # @param output [IO] The stream to write output to.
    def initialize(cli_name, schema, client, output)
      @cli_name = cli_name
      @schema = schema
      @client = client
      @output = output
    end

    # The command name.
    def name
      "#{@schema.resource_name}:#{@schema.name}"
    end

    # The command description.
    def description
      @schema.description
    end

    # Write usage information to the output stream.
    def usage
      @output.write <<-USAGE
Usage: #{@cli_name} #{name}

Description:
  #{description}
USAGE
    end

    # Run the command and write the results to the output stream.
    #
    # @param parameters [Array] The parameters to pass when making a request
    #   to run the command.
    def run(*parameters)
      result = @client.send(@schema.resource_name).send(@schema.name,
                                                        *parameters)
      result = result.to_a if result.instance_of?(Enumerator)
      result = MultiJson.dump(result) if result && !result.instance_of?(String)
      @output.write(result)
    end
  end
end
