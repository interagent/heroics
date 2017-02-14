# frozen_string_literal: true
require 'heroics'
require 'heroics/configuration'

class ConfigurationTest < MiniTest::Unit::TestCase
  def test_yields_itself_on_new_if_block_provided
    yielded_object = nil
    config = Heroics::Configuration.new { |c| yielded_object = c }
    assert_equal(yielded_object, config)
  end

  def test_default_ruby_name_replacement_patterns
    # No configuration set up beforehand

    assert(Heroics::Configuration.defaults.ruby_name_replacement_patterns.is_a?(Hash))
    assert_equal(Heroics::Configuration.defaults.ruby_name_replacement_patterns, { /[\s-]+/ => '_' })
  end

  def test_configuring_ruby_name_replacement_patterns
    patterns =  { /\s+/ => '_', /-/ => '' }

    Heroics.default_configuration do |c|
      c.ruby_name_replacement_patterns = patterns
    end

    assert(Heroics::Configuration.defaults.ruby_name_replacement_patterns.is_a?(Hash))
    assert_equal(Heroics::Configuration.defaults.ruby_name_replacement_patterns, patterns)

    Heroics::Configuration.restore_defaults
  end

  def test_restore_defaults_class_method
    patterns = { /\W+/ => '-' }
    Heroics.default_configuration do |c|
      c.ruby_name_replacement_patterns = patterns
    end

    assert_equal(Heroics::Configuration.defaults.ruby_name_replacement_patterns, patterns)

    Heroics::Configuration.restore_defaults

    refute_equal(Heroics::Configuration.defaults.ruby_name_replacement_patterns, patterns)
  end

  MiniTest::Unit.after_tests { |b| Heroics.default_configuration }
end
