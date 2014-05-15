require 'helper'

class ClientTest < MiniTest::Unit::TestCase
  include ExconHelper

  # Client.to_s returns a simple human-readable description of the client
  # instance with the URL embedded in it.  A password, if present in the URL,
  # is redacted to avoid leaking credentials.
  def test_to_s
    client = Heroics::Client.new({}, 'http://foo:bar@example.com')
    assert_equal('#<Heroics::Client url="http://foo:REDACTED@example.com">',
                 client.to_s)
  end

  # Client.<resource> raises a NoMethodError when a method is invoked
  # without a matching resource.
  def test_invalid_resource
    client = Heroics::Client.new({}, 'http://example.com')
    error = assert_raises NoMethodError do
      client.unknown
    end
    assert_equal("undefined method `unknown' for " +
                 '#<Heroics::Client url="http://example.com">',
                 error.message)
  end

  # Client.<resource>.<link> finds the appropriate link and invokes it.
  def test_resource
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://username:secret@example.com',
                             schema.resource('resource').link('list'))
    resource = Heroics::Resource.new({'link' => link})
    client = Heroics::Client.new({'resource' => resource},
                                 'http://example.com')
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
    client = Heroics::Client.new({'another-resource' => resource},
                                 'http://example.com')
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

class OAuthClientFromSchemaTest < MiniTest::Unit::TestCase
  include ExconHelper

  # oauth_client_from_schema injects an Authorization header, built from the
  # specified OAuth token, into the default header options.
  def test_oauth_client_from_schema
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal(
        'Bearer c55ef0d8-40b6-4759-b1bf-4a6f94190a66',
        request[:headers]['Authorization'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    oauth_token = 'c55ef0d8-40b6-4759-b1bf-4a6f94190a66'
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics.oauth_client_from_schema(oauth_token, schema,
                                              'https://example.com')
    assert_equal(body, client.resource.list)
  end

  # oauth_client_from_schema doesn't mutate the options object, and in
  # particular, it doesn't mutate the :default_headers Hash in that object.
  def test_oauth_client_from_schema_with_options
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      assert_equal(
        'Bearer c55ef0d8-40b6-4759-b1bf-4a6f94190a66',
        request[:headers]['Authorization'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    oauth_token = 'c55ef0d8-40b6-4759-b1bf-4a6f94190a66'
    options = {
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}}
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics.oauth_client_from_schema(oauth_token, schema,
                                              'https://example.com', options)
    assert_equal(body, client.resource.list)
  end
end

class TokenClientFromSchemaTest < MiniTest::Unit::TestCase
  include ExconHelper

  # token_client_from_schema injects an Authorization header, built from the
  # specified token, into the default header options.
  def test_token_client_from_schema
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal(
        'Token token=c55ef0d8-40b6-4759-b1bf-4a6f94190a66',
        request[:headers]['Authorization'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    token = 'c55ef0d8-40b6-4759-b1bf-4a6f94190a66'
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics.token_client_from_schema(token, schema,
                                              'https://example.com')
    assert_equal(body, client.resource.list)
  end

  # token_client_from_schema doesn't mutate the options object, and in
  # particular, it doesn't mutate the :default_headers Hash in that object.
  def test_token_client_from_schema_with_options
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      assert_equal(
        'Token token=c55ef0d8-40b6-4759-b1bf-4a6f94190a66',
        request[:headers]['Authorization'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    token = 'c55ef0d8-40b6-4759-b1bf-4a6f94190a66'
    options = {
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}}
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    client = Heroics.token_client_from_schema(token, schema,
                                              'https://example.com', options)
    assert_equal(body, client.resource.list)
  end
end
