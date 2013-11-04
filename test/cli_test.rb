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
    command1 = Heroics::Command.new('resource', schema1, properties, client,
                                    output)
    command2 = Heroics::Command.new('resource', schema2, properties, client,
                                    output)
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
    command1 = Heroics::Command.new('resource', schema1, properties, client,
                                    output)
    command2 = Heroics::Command.new('resource', schema2, properties, client,
                                    output)
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
end
