require 'helper'

class SanitizeNameTest < MiniTest::Unit::TestCase
  # sanitize_name is a no-op when an empty string is provided.
  def test_sanitize_name_with_empty_name
    assert_equal('', Heroics::sanitize_name(''))
  end

  # sanitize_name converts capitals in a name to lowercase.
  def test_sanitize_name_with_capitals
    assert_equal('capitalizedname', Heroics::sanitize_name('CapitalizedName'))
  end

  # sanitize_name converts dashes in a name to underscores.
  def test_sanitize_name_with_dashes
    assert_equal('dashed_name', Heroics::sanitize_name('dashed-name'))
  end

  # sanitize_name converts spaces in a name to underscores.
  def test_sanitize_name_with_spaces
    assert_equal('spaced_name', Heroics::sanitize_name('spaced name'))
  end
end
