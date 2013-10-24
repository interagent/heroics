require 'helper'
require 'time'

class LinkTest < MiniTest::Test
  include ExconHelper

  def setup
    super
    @url = 'https://username:secret@example.com'
  end

  # Link.run invokes a request against the service identified by the URL.  The
  # path is left unchanged when parameters aren't required and the username
  # and password from the URL are passed using HTTP basic auth.
  def test_run_without_parameters_and_with_empty_response
    link = Heroics::Link.new(@url, '/resource', :get)
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end
    assert_equal(nil, link.run)
  end

  # Link.run injects parameters into the path in the order they were received.
  def test_run_with_parameters_and_empty_response
    path = '/resource/{(%23%2Fbool)}/{(%23%2Ftime)}/{(%23%2Fint)}/{(%23%2Fstr)}'
    link = Heroics::Link.new(@url, path, :get)
    Excon.stub(method: :get) do |request|
      assert_equal('/resource/true/2013-01-01T00:00:00Z/42/hello',
                   request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end
    assert_equal(nil, link.run(true, Time.utc(2013), 42, 'hello'))
  end

  # Link.run injects parameters into the path in the order they were received.
  # It correctly identifies parameters with multiple encoded slashes.
  def test_run_with_parameters_containing_multiple_encoded_slashes
    uuid = 'a72139f8-7737-4def-9e0f-19b6291a93d2'
    path = '/resource/{(%23%2Fa%2Flong%2Fparameter%2Fname)}'
    link = Heroics::Link.new(@url, path, :get)
    Excon.stub(method: :get) do |request|
      assert_equal('/resource/42', request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end
    assert_equal(nil, link.run(42))
  end

  # Link.run converts Time parameters to UTC before sending them to the
  # server.
  def test_run_converts_time_parameters_to_utc
    path = '/resource/{(%23%2Ftime)}'
    link = Heroics::Link.new(@url, path, :get)
    Excon.stub(method: :get) do |request|
      assert_equal("/resource/2013-01-01T08:00:00Z", request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end
    assert_equal(nil, link.run(Time.parse('2013-01-01 00:00:00-0800')))
  end

  # Link.run optionally takes an extra parameter to send in the request body.
  def test_run_without_parameters_and_with_request_body
    body = {'Hello' => 'world!'}
    link = Heroics::Link.new(@url, '/resource', :post)
    Excon.stub(method: :post) do |request|
      assert_equal('/resource', request[:path])
      assert_equal(body, MultiJson.load(request[:body]))
      Excon.stubs.pop
      {status: 200, body: ''}
    end
    assert_equal(nil, link.run(body))
  end

  # Link.run returns text responses sent by the server without processing them
  # in any way.
  def test_run_with_text_response
    link = Heroics::Link.new(@url, '/resource', :get)
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/text'},
       body: "Hello, world!\r\n"}
    end
    assert_equal("Hello, world!\r\n", link.run)
  end

  # Link.run automatically decodes JSON responses sent by the server into Ruby
  # objects.
  def test_run_with_json_response
    body = {'Hello' => 'World!'}
    link = Heroics::Link.new(@url, '/resource', :get)
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, link.run)
  end

  # Link.run automatically decodes JSON responses with a complex Content-Type
  # header sent by the server into Ruby objects.
  def test_run_with_json_response_and_complex_content_type
    body = {'Hello' => 'World!'}
    link = Heroics::Link.new(@url, '/resource', :get)
    Excon.stub(method: :get) do |request|
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200,
       headers: {'Content-Type' => 'application/json;charset=utf-8'},
       body: MultiJson.dump(body)}
    end
    assert_equal(body, link.run)
  end

  # Link.run raises an ArgumentError if too few parameters are provided.
  def test_run_with_missing_parameters
    path = '/resource/{(%23%2Fparameter)}'
    link = Heroics::Link.new(@url, path, :get)
    error = assert_raises ArgumentError do
      link.run
    end
    assert_equal('wrong number of arguments (0 for 1)', error.message)
  end

  # Link.run raises an ArgumentError if too many parameters are provided.
  def test_run_with_too_many_parameters
    path = '/resource/{(%23%2Fparameter)}'
    link = Heroics::Link.new(@url, path, :get)
    error = assert_raises ArgumentError do
      link.run('too', 'many', 'parameters')
    end
    assert_equal('wrong number of arguments (3 for 1)', error.message)
  end
end
