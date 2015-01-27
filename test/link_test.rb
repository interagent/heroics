require 'helper'

class LinkTest < MiniTest::Unit::TestCase
  include ExconHelper

  # Link.run invokes a request against the service identified by the URL.  The
  # path is left unchanged when parameters aren't required and the username
  # and password from the URL are passed using HTTP basic auth.
  def test_run_without_parameters_and_with_empty_response
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://username:secret@example.com',
                             schema.resource('resource').link('list'))
    assert_equal(nil, link.run)
  end

  # Link.run injects parameters into the path in the order they were received.
  def test_run_with_parameters_and_empty_response
    Excon.stub(method: :get) do |request|
      assert_equal('/resource/44724831-bf66-4bc2-865f-e2c4c2b14c78',
                   request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('info'))
    assert_equal(nil, link.run('44724831-bf66-4bc2-865f-e2c4c2b14c78'))
  end

  # Link.run converts Time parameters to UTC before sending them to the
  # server.
  def test_run_converts_time_parameters_to_utc
    Excon.stub(method: :delete) do |request|
      assert_equal("/resource/2013-01-01T08:00:00Z", request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('delete'))
    assert_equal(nil, link.run(Time.parse('2013-01-01 00:00:00-0800')))
  end

  # Link.run optionally takes an extra parameter to send in the request body.
  # It automatically converts the specified object to JSON and includes a
  # Content-Type header in the request.
  def test_run_without_parameters_and_with_request_body
    body = {'Hello' => 'world!'}
    Excon.stub(method: :post) do |request|
      assert_equal('application/json', request[:headers]['Content-Type'])
      assert_equal(body, MultiJson.load(request[:body]))
      Excon.stubs.pop
      {status: 200, body: ''}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('create'))
    assert_equal(nil, link.run(body))
  end

  # Link.run optionally takes an extra parameter to send in the request body.
  # It automatically converts the specified object to the specified encoding
  # type and includes a Content-Type header in the request
  def test_run_without_parameters_and_with_non_json_request_body
    body = {'Hello' => 'world!'}
    Excon.stub(method: :post) do |request|
      assert_equal('application/x-www-form-urlencoded', request[:headers]['Content-Type'])
      assert_equal('Hello=world%21', request[:body])
      Excon.stubs.pop
      {status: 200, body: ''}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('submit'))
    assert_equal(nil, link.run(body))
  end


  # Link.run passes custom headers to the server when they've been provided.
  def test_run_with_custom_request_headers
    Excon.stub(method: :get) do |request|
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new(
      'https://example.com', schema.resource('resource').link('list'),
      {default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}})
    assert_equal(nil, link.run())
  end

  # Link.run passes custom headers to the server when they've been provided.
  # It merges in the Content-Type when a body is included in the request.
  def test_run_with_custom_request_headers_and_with_request_body
    body = {'Hello' => 'world!'}
    Excon.stub(method: :post) do |request|
      assert_equal('application/json', request[:headers]['Content-Type'])
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      assert_equal(body, MultiJson.load(request[:body]))
      Excon.stubs.pop
      {status: 200}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new(
      'https://example.com', schema.resource('resource').link('create'),
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'})
    assert_equal(nil, link.run(body))
  end

  # Link.run doesn't mutate the default headers.
  def test_run_never_overwrites_default_headers
    body = {'Hello' => 'world!'}
    Excon.stub(method: :post) do |request|
      assert_equal('application/json', request[:headers]['Content-Type'])
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      assert_equal(body, MultiJson.load(request[:body]))
      Excon.stubs.pop
      {status: 200}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new(
      'https://example.com', schema.resource('resource').link('create'),
      {default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}})
    assert_equal(nil, link.run(body))

    # The second time we use the link, without providing a request body, the
    # Content-Type set during the first run is not present, as expected.
    Excon.stub(method: :post) do |request|
      assert_equal(nil, request[:headers]['Content-Type'])
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200}
    end
    assert_equal(nil, link.run)
  end

  # Link.run returns text responses sent by the server without processing them
  # in any way.
  def test_run_with_text_response
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/text'},
       body: "Hello, world!\r\n"}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'))
    assert_equal("Hello, world!\r\n", link.run)
  end

  # Link.run automatically decodes JSON responses sent by the server into Ruby
  # objects.
  def test_run_with_json_response
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 201, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('create'))
    assert_equal(body, link.run)
  end

  # Link.run automatically decodes JSON responses with a complex Content-Type
  # header sent by the server into Ruby objects.
  def test_run_with_json_response_and_complex_content_type
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200,
       headers: {'Content-Type' => 'application/json;charset=utf-8'},
       body: MultiJson.dump(body)}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'))
    assert_equal(body, link.run)
  end

  # Link.run considers HTTP 202 Accepted responses as successful.
  def test_run_with_accepted_request
    body = {'Hello' => 'World!'}
    Excon.stub(method: :post) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 202, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('create'))
    assert_equal(body, link.run)
  end

  # Link.run raises an Excon error if anything other than a 200 or 201 HTTP
  # status code was returned by the server.
  def test_run_with_failed_request
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 400}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'))
    assert_raises Excon::Errors::BadRequest do
      link.run
    end
  end

  # Link.run raises an ArgumentError if too few parameters are provided.
  def test_run_with_missing_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('info'))
    error = assert_raises ArgumentError do
      link.run
    end
    assert_equal('wrong number of arguments (0 for 1)', error.message)
  end

  # Link.run raises an ArgumentError if too many parameters are provided.
  def test_run_with_too_many_parameters
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('info'))
    error = assert_raises ArgumentError do
      link.run('too', 'many', 'parameters')
    end
    assert_equal('wrong number of arguments (3 for 1)', error.message)
  end

  # Link.run passes ETags from the cache to the server with GET requests.
  def test_run_passes_cached_etags_in_get_requests
    Excon.stub(method: :get) do |request|
      assert_equal('etag-contents', request[:headers]['If-None-Match'])
      Excon.stubs.pop
      {status: 200}
    end

    cache = Moneta.new(:Memory)
    cache['etag:/resource:0'] = 'etag-contents'
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'),
                             cache: cache)
    link.run
  end

  # Link.run will not pas ETags from the cache for non-GET requests.
  def test_run_ignores_etags_for_non_get_requests
    Excon.stub(method: :post) do |request|
      assert_equal(nil, request[:headers]['If-None-Match'])
      Excon.stubs.pop
      {status: 201}
    end

    cache = Moneta.new(:Memory)
    cache['etag:/resource:0'] = 'etag-contents'
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('create'),
                             cache: cache)
    link.run({'Hello' => 'World'})
  end

  # Link.run returns JSON content loaded from the cache when a GET request
  # with an ETag yields a 304 Not Modified response.
  def test_run_returns_cached_json_content_for_not_modified_response
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      assert_equal('etag-contents', request[:headers]['If-None-Match'])
      Excon.stubs.pop
      {status: 304, headers: {'Content-Type' => 'application/json'}}
    end

    cache = Moneta.new(:Memory)
    cache['etag:/resource:0'] = 'etag-contents'
    cache['data:/resource:0'] = MultiJson.dump(body)
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'),
                             cache: cache)
    assert_equal(body, link.run)
  end

  # Link.run caches JSON content received from the server when an ETag is
  # included in the response.
  def test_run_caches_json_body_when_an_etag_is_received
    body = {'Hello' => 'World!'}
    Excon.stub(method: :get) do |request|
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json',
                              'ETag' => 'etag-contents'},
       body: MultiJson.dump(body)}
    end

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'),
                             cache: Moneta.new(:Memory))
    assert_equal(body, link.run)

    Excon.stub(method: :get) do |request|
      assert_equal('etag-contents', request[:headers]['If-None-Match'])
      Excon.stubs.pop
      {status: 304, headers: {'Content-Type' => 'application/json'}}
    end
    assert_equal(body, link.run)
  end

  # Link.run returns an enumerator when a 206 Partial Content status code and
  # Content-Range header is included in a server response.  The enumerator
  # makes requests to fetch missing pages as its iterated.
  def test_run_with_range_response
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

    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://example.com',
                             schema.resource('resource').link('list'))
    assert_equal([1, 2], link.run.to_a)
  end
end
