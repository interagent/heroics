require 'helper'
require 'stringio'

class CLITest < MiniTest::Test
  include ExconHelper

  # CLI.run displays usage information when no arguments are provided.
  def test_run_without_arguments
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    properties = SAMPLE_SCHEMA['definitions']['resource']['definitions']
    output = StringIO.new
    schema1 = SAMPLE_SCHEMA['definitions']['resource']['links'][0]
    schema2 = SAMPLE_SCHEMA['definitions']['resource']['links'][1]
    command1 = Heroics::Command.new('cli', 'resource', schema1, properties,
                                    client, output)
    command2 = Heroics::Command.new('cli', 'resource', schema2, properties,
                                    client, output)
    cli = Heroics::CLI.new('cli', {'resource:list' => command1,
                                   'resource:info' => command2}, output)
    cli.run
    expected = <<-USAGE
Usage: cli <command> [<parameter> [...]] [<body>]

Help topics, type "cli help <topic>" for more details:

  resource:info    Show a sample resource
  resource:list    Show all sample resources
USAGE
    assert_equal(expected, output.string)
  end

  # CLI.run displays usage information when the help command is specified.
  def test_run_with_help_command
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    properties = SAMPLE_SCHEMA['definitions']['resource']['definitions']
    output = StringIO.new
    schema1 = SAMPLE_SCHEMA['definitions']['resource']['links'][0]
    schema2 = SAMPLE_SCHEMA['definitions']['resource']['links'][1]
    command1 = Heroics::Command.new('cli', 'resource', schema1, properties,
                                    client, output)
    command2 = Heroics::Command.new('cli', 'resource', schema2, properties,
                                    client, output)
    cli = Heroics::CLI.new('cli', {'resource:list' => command1,
                                   'resource:info' => command2}, output)
    cli.run('help')
    expected = <<-USAGE
Usage: cli <command> [<parameter> [...]] [<body>]

Help topics, type "cli help <topic>" for more details:

  resource:info    Show a sample resource
  resource:list    Show all sample resources
USAGE
    assert_equal(expected, output.string)
  end

  # CLI.run displays command-specific help when a command name is included
  # with the 'help' command.
  def test_run_with_help_command_and_explicit_command_name
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    properties = SAMPLE_SCHEMA['definitions']['resource']['definitions']
    output = StringIO.new
    schema1 = SAMPLE_SCHEMA['definitions']['resource']['links'][0]
    schema2 = SAMPLE_SCHEMA['definitions']['resource']['links'][1]
    command1 = Heroics::Command.new('cli', 'resource', schema1, properties,
                                    client, output)
    command2 = Heroics::Command.new('cli', 'resource', schema2, properties,
                                    client, output)
    cli = Heroics::CLI.new('cli', {'resource:list' => command1,
                                   'resource:info' => command2}, output)
    cli.run('help', 'resource:info')
    expected = <<-USAGE
Usage: cli <command> [<parameter> [...]] [<body>]

Help topics, type "cli help <topic>" for more details:

  resource:info    Show a sample resource
  resource:list    Show all sample resources
USAGE
    assert_equal(expected, output.string)
  end

  # CLI.run displays an error message when no commands have been registered.
  def test_run_without_commands
    output = StringIO.new
    cli = Heroics::CLI.new('cli', {}, output)
    cli.run('help')
    assert_equal('No commands are available.', output.string)
  end

  # CLI.run displays an error message when an unknown command name is used.
  def test_run_with_unknown_name
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    properties = SAMPLE_SCHEMA['definitions']['resource']['definitions']
    output = StringIO.new
    schema = SAMPLE_SCHEMA['definitions']['resource']['links'][0]
    command = Heroics::Command.new('cli', 'resource', schema, properties,
                                   client, output)
    cli = Heroics::CLI.new('cli', {'resource:list' => command}, output)
    cli.run('unknown:command')
    assert_equal("There is no command called 'unknown:command'.",
                 output.string)
  end

  # CLI.run runs the command matching the specified name.
  def test_run
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    schema = SAMPLE_SCHEMA['definitions']['resource']['links'][0]
    properties = SAMPLE_SCHEMA['definitions']['resource']['definitions']
    output = StringIO.new
    command = Heroics::Command.new('cli', 'resource', schema, properties,
                                   client, output)
    cli = Heroics::CLI.new('cli', {'resource:list' => command}, output)

    body = ['Hello', 'World!']
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    cli.run('resource:list')
    assert_equal(MultiJson.dump(body), output.string)
  end

  # CLI.run runs the command matching the specified name and passes parameters
  # to it.
  def test_run_with_parameters
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    schema = SAMPLE_SCHEMA['definitions']['resource']['links'][3]
    properties = SAMPLE_SCHEMA['definitions']['resource']['definitions']
    output = StringIO.new
    command = Heroics::Command.new('cli', 'resource', schema, properties,
                                   client, output)
    cli = Heroics::CLI.new('cli', {'resource:update' => command}, output)

    uuid = '1ab1c589-df46-40aa-b786-60e83b1efb10'
    body = {'Hello' => 'World!'}
    result = {'Goodbye' => 'Universe!'}
    Excon.stub(method: :patch) do |request|
      assert_equal("/resource/#{uuid}", request[:path])
      assert_equal('application/json', request[:headers]['Content-Type'])
      assert_equal(body, MultiJson.load(request[:body]))
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(result)}
    end

    cli.run('resource:update', uuid, body)
    assert_equal(MultiJson.dump(result), output.string)
  end
end
