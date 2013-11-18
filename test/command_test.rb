require 'helper'
require 'stringio'

class CommandTest < MiniTest::Unit::TestCase
  include ExconHelper

  # Command.name returns the name of the command, which is made up by joining
  # the resource name and link title with a colon.
  def test_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('list'), client, output)
    assert_equal('resource:list', command.name)
  end

  # Command.description returns a description for the command.
  def test_description
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('list'), client, output)
    assert_equal('Show all sample resources', command.description)
  end

  # Command.run calls the correct method on the client when no link parameters
  # are provided.
  def test_run_without_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('list'), client, output)

    body = ['Hello', 'World!']
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    command.run
    assert_equal(MultiJson.dump(body, pretty: true) + "\n", output.string)
  end

  # Command.run calls the correct method on the client and passes link
  # parameters when they're provided.
  def test_run_with_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('info'), client, output)

    uuid = '1ab1c589-df46-40aa-b786-60e83b1efb10'
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal("/resource/#{uuid}", request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    command.run(uuid)
    assert_equal(MultiJson.dump(body, pretty: true) + "\n", output.string)
  end

  # Command.run calls the correct method on the client and passes a request
  # body to the link when it's provided.
  def test_run_with_request_body_and_text_response
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('create'), client, output)

    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('/resource', request[:path])
      assert_equal('application/json', request[:headers]['Content-Type'])
      assert_equal(body, MultiJson.load(request[:body]))
      Excon.stubs.pop
      {status: 201}
    end

    command.run(body)
    assert_equal('', output.string)
  end

  # Command.run calls the correct method on the client and converts the result
  # to an array, if a range response is received, before writing it out.
  def test_run_with_range_response
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('list'), client, output)

    Excon.stub(method: :get) do |request|
      Excon.stubs.shift
      {status: 206, headers: {'Content-Type' => 'application/json',
                              'Content-Range' => 'id 1..2; max=200'},
       body: MultiJson.dump([2])}
    end

    Excon.stub(method: :get) do |request|
      Excon.stubs.shift
      {status: 206, headers: {'Content-Type' => 'application/json',
                              'Content-Range' => 'id 0..1; max=200',
                              'Next-Range' => '201'},
       body: MultiJson.dump([1])}
    end

    command.run
    assert_equal(MultiJson.dump([1, 2], pretty: true) + "\n", output.string)
  end

  # Command.run calls the correct method on the client and passes parameters
  # and a request body to the link when they're provided.
  def test_run_with_request_body_and_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('update'), client, output)

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

    command.run(uuid, body)
    assert_equal(MultiJson.dump(result, pretty: true) + "\n", output.string)
  end

  # Command.run raises an ArgumentError if too few parameters are provided.
  def test_run_with_too_few_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('info'), client, output)
    assert_raises ArgumentError do
      command.run
    end
  end

  # Command.run raises an ArgumentError if too many parameters are provided.
  def test_run_with_too_many_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('info'), client, output)
    assert_raises ArgumentError do
      command.run('too', 'many', 'parameters')
    end
  end

  # Command.usage displays usage information.
  def test_usage
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('update'), client, output)
    command.usage
    expected = <<-USAGE
Usage: cli resource:update <uuid_field> <body>

Description:
  Update a sample resource

Body example:
  {
    "date_field": "2013-10-19 22:10:29Z",
    "string_field": "Sample text.",
    "boolean_field": true,
    "uuid_field": "44724831-bf66-4bc2-865f-e2c4c2b14c78",
    "email_field": "username@example.com"
  }
USAGE
    assert_equal(expected, output.string)
  end

  # Command.usage correctly handles parameters that are described by 'oneOf'
  # and 'anyOf' sub-parameter lists.
  def test_usage_with_one_of_field
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    output = StringIO.new
    command = Heroics::Command.new(
      'cli', schema.resource('resource').link('identify_resource'), client,
      output)
    command.usage
    expected = <<-USAGE
Usage: cli resource:identify-resource <uuid_field|email_field>

Description:
  Show a sample resource
USAGE
    assert_equal(expected, output.string)
  end
end
