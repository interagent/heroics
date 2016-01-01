# frozen_string_literal: true
module Heroics
  class Command
    # Instantiate a command.
    #
    # @param cli_name [String] The name of the CLI.
    # @param link_schema [LinkSchema] The schema for the underlying link this
    #   command represents.
    # @param client [Client] The client to use when making requests.
    # @param output [IO] The stream to write output to.
    def initialize(cli_name, link_schema, client, output)
      @cli_name = cli_name
      @link_schema = link_schema
      @client = client
      @output = output
    end

    # The command name.
    def name
      "#{@link_schema.pretty_resource_name}:#{@link_schema.pretty_name}"
    end

    # The command description.
    def description
      @link_schema.description
    end

    # Write usage information to the output stream.
    def usage
      parameters = @link_schema.parameters.map { |parameter| "<#{parameter}>" }
      parameters = parameters.empty? ? '' : " #{parameters.join(' ')}"
      example_body = @link_schema.example_body
      body_parameter = example_body.nil? ? '' : ' <body>'
      @output.write <<-USAGE
Usage: #{@cli_name} #{name}#{parameters}#{body_parameter}

Description:
  #{description}
USAGE
      if example_body
        example_body = MultiJson.dump(example_body, pretty: true)
        example_body = example_body.lines.map do |line|
          "  #{line}"
        end.join
        @output.write <<-USAGE

Body example:
#{example_body}
USAGE
      end
    end

    # Run the command and write the results to the output stream.
    #
    # @param parameters [Array] The parameters to pass when making a request
    #   to run the command.
    def run(*parameters)
      resource_name = @link_schema.resource_name
      name = @link_schema.name
      result = @client.send(resource_name).send(name, *parameters)
      result = result.to_a if result.instance_of?(Enumerator)
      if result && !result.instance_of?(String)
        result = MultiJson.dump(result, pretty: true)
      end
      @output.puts(result) unless result.nil?
    end
  end
end
