require 'helper'

class SchemaTest < MiniTest::Unit::TestCase
  # Schema.to_s returns a simple human-readable description of the schema
  # instance with the description embedded in it.
  def test_to_s
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal(
      '#<Heroics::Schema description="Sample schema for use in tests.">',
      schema.to_s)
  end

  # Schema.resource returns a ResourceSchema for the named resource.
  def test_resource
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('resource', schema.resource('resource').name)
  end

  # Schema.resource raises a SchemaError is an unknown resource is requested.
  def test_resource_with_unknown_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    error = assert_raises Heroics::SchemaError do
      schema.resource('unknown-resource')
    end
    assert_equal("Unknown resource 'unknown-resource'.", error.message)
  end

  # Schema.resources returns a sequence of ResourceSchema children.
  def test_resources
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal(['resource', 'another-resource'],
                 schema.resources.map(&:name))
  end
end

class ResourceSchemaTest < MiniTest::Unit::TestCase
  # ResourceSchema.link returns a LinkSchema for the named link.
  def test_link
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('list')
    assert_equal('list', link.name)
  end

  # ResourceSchema.link raises a SchemaError is an unknown link is requested.
  def test_link_with_unknown_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    error = assert_raises Heroics::SchemaError do
      schema.resource('resource').link('unknown-link')
    end
    assert_equal("Unknown link 'unknown-link'.", error.message)
  end

  # ResourceSchema.links returns an array of LinkSchema children.
  def test_links
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal(
      ['list', 'info', 'identify_resource', 'create', 'update', 'delete'],
      schema.resource('resource').links.map { |link| link.name })
  end
end

class LinkSchemaTest < MiniTest::Unit::TestCase
  # LinkSchema.name returns the sanitized link name.
  def test_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('list', schema.resource('resource').link('list').name)
  end

  # LinkSchema.resource_name returns the parent resource name.
  def test_resource_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('resource',
                 schema.resource('resource').link('list').resource_name)
  end

  # LinkSchema.description returns the link description.
  def test_description
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('Show all sample resources',
                 schema.resource('resource').link('list').description)
  end

  # LinkSchema.parameters returns an empty array if the link doesn't require
  # parameters.
  def test_parameters_without_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('list')
    assert_equal([], link.parameters)
  end

  # LinkSchema.parameters returns an array of named parameter required to
  # invoke the link correctly.
  def test_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    assert_equal(['uuid_field'], link.parameters)
  end

  # LinkSchema.parameters returns a parameter name for multiple parameters
  # when the parameter contains a 'oneOf' element that references more than
  # one parameter.
  def test_parameters_with_one_of_field
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('identify_resource')
    assert_equal(['uuid_field|email_field'], link.parameters)
  end

  # LinkSchema.parameter_details returns an empty array if the link doesn't
  # require parameters.
  def test_parameter_details_without_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('list')
    assert_equal([], link.parameter_details)
  end

  # LinkSchema.parameter_details returns an array of hashes with information
  # about the parameters accepted by the link.
  def test_parameter_details
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    assert_equal([{name: 'uuid_field',
                   description: 'A sample UUID field'}],
                 link.parameter_details)
  end

  # LinkSchema.parameter_details returns an array of hashes with information
  # about the parameters accepted by the link.  If the parameter is part of a
  # 'oneOf' set of parameters the names are concatenated with '_or_' and the
  # descriptions are bundled together.
  def test_parameter_details_with_one_of_field
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('identify_resource')
    assert_equal(
      [{name: 'uuid_field_or_email_field',
        description: 'A sample UUID field or A sample email address field'}],
      link.parameter_details)
  end

  # LinkSchema.body returns nil if the link doesn't accept a request body.
  def test_example_body_without_body
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    assert_equal(nil, link.example_body)
  end

  # LinkSchema.body returns a sample body generated from the properties and
  # embedded examples.
  def test_example_body
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('create')
    assert_equal({'date_field' => '2013-10-19 22:10:29Z',
                  'string_field' => 'Sample text.',
                  'boolean_field' => true,
                  'uuid_field' => '44724831-bf66-4bc2-865f-e2c4c2b14c78',
                  'email_field' => 'username@example.com'},
                 link.example_body)
  end

  # LinkSchema.format_path converts an array of parameters into a path.
  def test_format_path
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    assert_equal(['/resource/44724831-bf66-4bc2-865f-e2c4c2b14c78', nil],
                 link.format_path(['44724831-bf66-4bc2-865f-e2c4c2b14c78']))
  end

  # LinkSchema.format_path correctly returns a parameter as a body if a path
  # doesn't have any parameters.
  def test_format_path_with_body
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('create')
    assert_equal(['/resource', {'new' => 'resource'}],
                 link.format_path([{'new' => 'resource'}]))
  end

  # LinkSchema.format_path correctly returns a parameter as a body if a path
  # doesn't have any parameters.
  def test_format_path_with_path_and_body
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('update')
    assert_equal(['/resource/44724831-bf66-4bc2-865f-e2c4c2b14c78',
                  {'new' => 'resource'}],
                 link.format_path(['44724831-bf66-4bc2-865f-e2c4c2b14c78',
                                   {'new' => 'resource'}]))
  end

  # LinkSchema.format_path raises an ArgumentError if too few parameters are
  # provided
  def test_format_path_with_too_few_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    error = assert_raises ArgumentError do
      link.format_path([])
    end
    assert_equal('wrong number of arguments (0 for 1)', error.message)
  end

  # LinkSchema.format_path raises an ArgumentError if too many parameters are
  # provided
  def test_format_path_with_too_many_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    error = assert_raises ArgumentError do
      link.format_path(['too', 'many', 'parameters'])
    end
    assert_equal('wrong number of arguments (3 for 1)', error.message)
  end

  # LinkSchema.pretty_resource_name returns the resource name in a pretty
  # form, with underscores converted to dashes.
  def test_pretty_resource_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('another-resource').link('list')
    assert_equal('another-resource', link.pretty_resource_name)
  end

  # LinkSchema.pretty_name returns the link name in a pretty form, with
  # underscores converted to dashes.
  def test_pretty_resource_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('identify_resource')
    assert_equal('identify-resource', link.pretty_name)
  end
end

class DownloadSchemaTest < MiniTest::Unit::TestCase
  include ExconHelper

  # download_schema makes a request to fetch the schema, decodes the
  # downloaded JSON and returns a Ruby hash.
  def test_download_schema
    Excon.stub(method: :get) do |request|
      assert_equal('example.com', request[:host])
      assert_equal('/schema', request[:path])
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(SAMPLE_SCHEMA)}
    end

    schema = Heroics::download_schema(
      'https://username:token@example.com/schema',
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'})
    assert_equal(SAMPLE_SCHEMA, schema.schema)
  end
end
