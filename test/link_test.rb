require 'helper'

class LinkTest < MiniTest::Test
  include ExconHelper

  def setup
    super
    @url = 'https://username:secret@example.com'
  end

  # Link.run invokes a GET request against the service identified by the URL.
  # The path is unchanged when no parameters aren't required and the username
  # and password are passed using HTTP basic auth.
  def test_run_get_request_without_arguments_and_empty_response
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
  def test_run_get_request_with_arguments_and_empty_response
    uuid = 'a72139f8-7737-4def-9e0f-19b6291a93d2'
    path = '/resource/{(#/bool)}/{(#/date)}/{(#/int)}/{(#/string)}/{(#/uuid)}'
    link = Heroics::Link.new(@url, path, :get)
    Excon.stub(method: :get) do |request|
      assert_equal("/resource/true/2013-01-01T00:00:00Z/42/hello/#{uuid}",
                   request[:path])
      Excon.stubs.pop
      {status: 200, body: ''}
    end
    assert_equal(nil, link.run(true, Time.utc(2013), 42, 'hello', uuid))
  end

  # Link.run returns text responses sent by the server without processing them
  # in any way.
  def test_run_get_request_with_text_response
    link = Heroics::Link.new(@url, '/resource', :get)
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/text'},
       body: 'Hello, world!'}
    end
    assert_equal('Hello, world!', link.run)
  end
end
