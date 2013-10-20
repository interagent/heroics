require 'helper'

class HTTPClientTest < MiniTest::Test
  include ExconHelper

  def setup
    super
    @client = Heroics::HTTPClient.new('https://username:secret@example.com',
                                      SAMPLE_SCHEMA)
  end

  # # HTTPClient raises a NoMethodError when a method that doesn't match the
  # # schema is used.
  # def test_invalid_method
  #   assert_raises NoMethodError do
  #     @client.invalid_method
  #   end
  # end

  # # HTTPClient.$resource.$link_name for a GET without parameters that receives
  # # an empty application/json response body from the server returns nil.
  # def test_get_without_parameters_and_empty_json_response_body
  #   url = 'https://username:password@example.com'
  #   client = Heroics::HTTPClient.new(url, SAMPLE_SCHEMA)
  #   Excon.stub(method: :get) do |request|
  #     assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
  #                  request[:headers]['Authorization'])
  #     assert_equal('example.com', request[:host])
  #     assert_equal('443', request[:port])
  #     assert_equal('/resource', request[:path])
  #     Excon.stubs.pop
  #   end
  #   assert_equal({'sample' => 'data'}, @client.resource.list)
  # end
end
