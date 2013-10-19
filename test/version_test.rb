require 'helper'

class VersionTest < MiniTest::Test
  # Heroics::VERSION defines version for the project in MAJOR.MINOR.PATCH
  # format.
  def test_version
    assert_match(/\d+.\d+.\d+/, Heroics::VERSION)
  end
end
