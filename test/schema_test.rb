require 'helper'

class SchemaTest < MiniTest::Test
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
    puts schema.resources
    assert_equal(['resource'], schema.resources.map(&:name))
  end
end

class ResourceSchemaTest < MiniTest::Test
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

  # ResourceSchema.links returns a list of LinkSchema children.
  def test_links
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal(['list', 'info', 'create', 'update', 'delete'],
                 schema.resource('resource').links.map { |link| link.name })
  end
end

class LinkSchemaTest < MiniTest::Test
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

  # LinkSchema.parameters returns an empty list if the link doesn't require
  # parameters.
  def test_parameters_without_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('list')
    assert_equal([], link.parameters)
  end

  # LinkSchema.parameters returns a list of named parameter required to invoke
  # the link correctly.
  def test_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    assert_equal(['uuid_field'], link.parameters)
  end

  # LinkSchema.body returns nil if the link doesn't accept a request body.
  def test_body_without_body
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('info')
    assert_equal(nil, link.body)
  end

  # LinkSchema.body returns a sample body generated from the properties and
  # embedded examples.
  def test_body
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = schema.resource('resource').link('create')
    assert_equal({'date_field' => '2013-10-19 22:10:29Z',
                  'string_field' => 'Sample text.',
                  'boolean_field' => true,
                  'uuid_field' => '44724831-bf66-4bc2-865f-e2c4c2b14c78',
                  'email_field' => 'username@example.com'},
                 link.body)
  end

  # LinkSchema.format_path converts a list of parameters into a path.
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
end

class DownloadSchemaTest < MiniTest::Test
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
