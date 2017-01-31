# frozen_string_literal: true

class ConfigurationTest < MiniTest::Unit::TestCase
  def yields_itself_on_new_if_block_provided
    yielded_object = nil
    config = Configuration.new { |c| yielded_object = c }
    assert_equal(yielded_object, config)
  end


end
