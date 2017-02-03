# frozen_string_literal: true

require 'heroics/configuration'

class ConfigurationTest < MiniTest::Unit::TestCase
  def test_yields_itself_on_new_if_block_provided
    yielded_object = nil
    config = Heroics::Configuration.new { |c| yielded_object = c }
    assert_equal(yielded_object, config)
  end


end
