require 'helper'

class HTTPClientTest < MiniTest::Test
  # HTTPClient raises a NoMethodError when a method that doesn't match the
  # schema is used.
  def test_invalid_method
    url = 'https://username:password@example.com'
    client = Heroics::HTTPClient.new(url, SAMPLE_SCHEMA)
    assert_raises NoMethodError do
      client.invalid_method
    end
  end

  def test_get
end
