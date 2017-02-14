# frozen_string_literal: true

require 'heroics'

class HeroicsTest < MiniTest::Unit::TestCase
  def test_default_configuration
    assert_equal(Heroics.default_configuration.class, Heroics::Configuration)
  end

  def test_yields_configuration_if_block_given
    yielded = nil

    Heroics.default_configuration { |c| yielded = c }

    assert_equal(yielded, Heroics.default_configuration)
  end
end
