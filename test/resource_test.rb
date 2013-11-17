require 'helper'

class ResourceTest < MiniTest::Test
  include ExconHelper

  # Resource.<link> raises a NoMethodError when a method is invoked without a
  # matching link.
  def test_invalid_link
    resource = Heroics::Resource.new({})
    error = assert_raises NoMethodError do
      resource.unknown
    end
    assert_match(
      /undefined method `unknown' for #<Heroics::Resource:0x[0-9a-f]{14}>/,
      error.message)
  end

  # Resource.<link> finds the appropriate link and invokes it.
  def test_link
    schema = Heroics::Schema.new(SAMPLE_SCHEMA)
    link = Heroics::Link.new('https://username:secret@example.com',
                             schema.resource('resource').link('list'))
    resource = Heroics::Resource.new({'link' => link})
    Excon.stub(method: :get) do |request|
      assert_equal('Basic dXNlcm5hbWU6c2VjcmV0',
                   request[:headers]['Authorization'])
      assert_equal('example.com', request[:host])
      assert_equal(443, request[:port])
      assert_equal('/resource', request[:path])
      Excon.stubs.pop
      {status: 200, body: 'Hello, world!'}
    end
    assert_equal('Hello, world!', resource.link)
  end
end
