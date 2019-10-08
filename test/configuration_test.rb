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

  def test_configuring_rate_throttle
    new_rate_throttle = lambda {}
    Heroics.default_configuration do |c|
      c.rate_throttle = new_rate_throttle
    end

    assert(Heroics::Configuration.defaults.options[:rate_throttle].is_a?(Proc))
    assert_equal(Heroics::Configuration.defaults.options[:rate_throttle], new_rate_throttle)

    Heroics::Configuration.restore_defaults
  end

  def test_configuring_status_codes
    Heroics.default_configuration do |c|
      c.acceptable_status_codes = [429]
    end

    assert(Heroics::Configuration.defaults.options[:status_codes].is_a?(Array))
    assert_equal(Heroics::Configuration.defaults.options[:status_codes], [429])

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
