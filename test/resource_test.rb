require 'helper'

class ResourceTest < MiniTest::Test
  include ExconHelper

  def setup
    super
    @resource = Heroics::Resource.new('resource', SAMPLE_SCHEMA)
  end

  # Resource.<method> raises a NoMethodError when a method is invoked without
  # a matching link.
  def test_invalid_method
    resource = Heroics::Resource.new('resource', [])
    error = assert_raises NoMethodError do
      @resource.unknown
    end
    assert_match(
      /undefined method `unknown' for #<Heroics::Resource:0x[0-9a-f]{14}>/,
      error.message)
  end
end
