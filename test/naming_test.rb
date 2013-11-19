require 'helper'

class RubyNameTest < MiniTest::Unit::TestCase
  # ruby_name is a no-op when an empty string is provided.
  def test_ruby_name_with_empty_name
    assert_equal('', Heroics.ruby_name(''))
  end

  # ruby_name converts capitals in a name to lowercase.
  def test_ruby_name_with_capitals
    assert_equal('capitalizedname', Heroics.ruby_name('CapitalizedName'))
  end

  # ruby_name converts dashes in a name to underscores.
  def test_ruby_name_with_dashes
    assert_equal('dashed_name', Heroics.ruby_name('dashed-name'))
  end

  # ruby_name converts spaces in a name to underscores.
  def test_ruby_name_with_spaces
    assert_equal('spaced_name', Heroics.ruby_name('spaced name'))
  end
end

class PrettyNameTest < MiniTest::Unit::TestCase
  # pretty_name is a no-op when an empty string is provided.
  def test_pretty_name_with_empty_name
    assert_equal('', Heroics.pretty_name(''))
  end

  # pretty_name converts capitals in a name to lowercase.
  def test_pretty_name_with_capitals
    assert_equal('capitalizedname', Heroics.pretty_name('CapitalizedName'))
  end

  # pretty_name converts underscores in a name to dashes.
  def test_pretty_name_with_underscores
    assert_equal('dashed-name', Heroics.pretty_name('dashed_name'))
  end

  # pretty_name converts spaces in a name to underscores.
  def test_pretty_name_with_spaces
    assert_equal('spaced-name', Heroics.pretty_name('spaced name'))
  end
end
