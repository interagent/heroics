module Heroics
  class Command
    # Instantiate a command.
    #
    # @param resource_name [String] The name of the resource.
    # @param schema [Hash] The link section of the JSON schema this command
    #   will run.
    # @param properties [Hash] The properties section of the JSON schema for
    #   the resource this command is part of.
    # @param client [Client] The client to use when making requests.
    # @param output [IO] The stream to write output to.
    def initialize(resource_name, schema, properties, client, output)
      @resource_name = resource_name
      @schema = schema
      @properties = properties
      @client = client
      @output = output
    end

    # The name of the command.
    def name
      title = Heroics::sanitize_name(@schema['title'])
      "#{@resource_name}:#{title}"
    end

    # The description.
    def description
      @schema['description']
    end

    def usage
    end

    # Run the command and write the results to the output stream.
    #
    # @param parameters [Array] The parameters to pass when making a request
    #   to run the command.
    def run(*parameters)
      title = Heroics::sanitize_name(@schema['title'])
      result = @client.send(@resource_name).send(title, *parameters)
      result = MultiJson.dump(result) if result && !result.instance_of?(String)
      @output.write(result)
    end
  end
end
