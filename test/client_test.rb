require 'helper'

class ClientTest < MiniTest::Unit::TestCase
  include ExconHelper

  # Client.<resource> raises a NoMethodError when a method is invoked
  # without a matching resource.
  def test_invalid_resource
    client = Heroics::Client.new({})
    error = assert_raises NoMethodError do
      client.unknown
    end
    assert_match(
      /undefined method `unknown' for #<Heroics::Client:0x[0-9a-f]{14}>/,
      error.message)
  end

  # Client.<resource>.<link> finds the appropriate link and invokes it.
  def test_resource
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://username:secret@example.com',
                             schema.resource('resource').link('list'))
    resource = Heroics::Resource.new({'link' => link})
    client = Heroics::Client.new({'resource' => resource})
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, body: 'Hello, world!'}
    end
    assert_equal('Hello, world!', client.resource.link)
  end

  # Client converts underscores in resource method names to dashes to match
  # names specified in the schema.
  def test_resource_with_dashed_name
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://username:secret@example.com',
                             schema.resource('another-resource').link('list'))
    resource = Heroics::Resource.new({'link' => link})
    client = Heroics::Client.new({'another-resource' => resource})
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/another-resource', request[:path])
      Excon.stubs.pop
      {status: 200, body: 'Hello, world!'}
    end
    assert_equal('Hello, world!', client.another_resource.link)
  end
end

class ClientFromSchemaTest < MiniTest::Unit::TestCase
  include ExconHelper

  # client_from_schema returns a Client generated from the specified schema.
  def test_client_from_schema
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com')
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, client.resource.create)
  end

  # client_from_schema returns a Client that can make requests to APIs mounted
  # under a prefix, such as http://example.com/api, for example.
  def test_client_from_schema_with_url_prefix
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com/api')
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('/api/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, client.resource.create)
  end

  # client_from_schema optionally accepts custom headers to pass with every
  # request made by the generated client.
  def test_client_from_schema_with_custom_headers
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(
      schema, 'https://example.com',
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'})
    Excon.stub(method: :post) do |request|
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200}
    end
    client.resource.create
  end

  # client_from_schema takes an optional :cache parameter which it uses when
  # constructing Link instances.
  def test_client_from_schema_with_cache
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      Excon.stubs.pop
      {status: 201, headers: {'Content-Type' => 'application/json',
                              'ETag' => 'etag-contents'},
       body: MultiJson.dump(body)}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics::client_from_schema(schema, 'https://example.com',
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
