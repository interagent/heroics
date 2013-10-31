require 'helper'

class ClientFromSchemaTest < MiniTest::Test
  include ExconHelper

  # client_from_schema returns a Client generated from the specified schema.
  def test_client_from_schema
    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com')
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, client.resource.create)
  end

  # client_from_schema optionally accepts custom headers to pass with every
  # request made by the generated client.
  def test_client_from_schema_with_custom_headers
    client = Heroics::client_from_schema(
      SAMPLE_SCHEMA, 'https://example.com',
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'})
    Excon.stub(method: :post) do |request|
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200}
    end
    client.resource.create
  end

  # client_from_schema raises a SchemaError exception if definitions are not
  # present in the specified schema.
  def test_client_from_schema_without_definitions
    error = assert_raises Heroics::SchemaError do
      Heroics::client_from_schema({}, 'https://example.com')
    end
    assert_equal("Missing top-level 'definitions' key.", error.message)
  end

  # client_from_schema raises a SchemaError exception if a resource doesn't
  # have a links key.
  def test_client_from_schema_without_links
    error = assert_raises Heroics::SchemaError do
      Heroics::client_from_schema({'definitions' => {'resource' => {}}},
                                  'https://example.com')
    end
    assert_equal("'resource' resource is missing 'links' key.", error.message)
  end

  # client_from_schema takes an optional :cache parameter.
  def test_client_from_schema_with_cache
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      Excon.stubs.pop
      {status: 201, headers: {'Content-Type' => 'application/json',
                              'ETag' => 'etag-contents'},
       body: MultiJson.dump(body)}
    end

    client = Heroics::client_from_schema(SAMPLE_SCHEMA, 'https://example.com',
                                         cache: Moneta.new(:Memory))
    assert_equal(body, client.resource.list)

    Excon.stub(method: :get) do |request|
      assert_equal('etag-contents', request[:headers]['If-None-Match'])
      Excon.stubs.pop
      {status: 304, headers: {'Content-Type' => 'application/json'}}
    end
    assert_equal(body, client.resource.list)
  end
end

class ClientFromSchemaURLTest < MiniTest::Test
  include ExconHelper

  # client_from_schema_url downloads a schema and returns a Client generated
  # from it.
  def test_client_from_schema_url
    Excon.stub(method: :get) do |request|
      assert_equal('example.com', request[:host])
      assert_equal('/schema', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(SAMPLE_SCHEMA)}
    end

    client = Heroics::client_from_schema_url('https://example.com/schema')
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('example.com', request[:host])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, client.resource.create)
  end

  # client_from_schema_url optionally accepts custom headers to include in the
  # request to download the schema.  The same headers are passed in requests
  # made by the generated client.
  def test_client_from_schema_url_with_custom_headers
    Excon.stub(method: :get) do |request|
      assert_equal('example.com', request[:host])
      assert_equal('/schema', request[:path])
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(SAMPLE_SCHEMA)}
    end

    client = Heroics::client_from_schema_url(
      'https://example.com/schema',
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'})
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, client.resource.create)
  end

  # client_from_schema_url raises an Excon error when the request to download
  # the schema fails.
  def test_client_from_schema_url_with_failed_request
    Excon.stub(method: :get) do |request|
      Excon.stubs.pop
      {status: 404}
    end

    assert_raises Excon::Errors::NotFound do
      Heroics::client_from_schema_url('https://example.com/schema')
    end
  end
end
