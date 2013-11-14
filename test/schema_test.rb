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
end

class LinkSchemaTest < MiniTest::Test
  # LinkScheme.name returns the sanitized link name.
  def test_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('list', schema.resource('resource').link('list').name)
  end

  # LinkScheme.resource_name returns the parent resource name.
  def test_resource_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('resource',
                 schema.resource('resource').link('list').resource_name)
  end

  # LinkScheme.description returns the link description.
  def test_description
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    assert_equal('Show all sample resources',
                 schema.resource('resource').link('list').description)
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
