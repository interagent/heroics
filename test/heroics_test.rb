# frozen_string_literal: true

class HeroicsTest < MiniTest::Unit::TestCase
  #describe ".default_configuration" do
    #it 'returns Configuration.default' do
      #expect(Interpol.default_configuration).to be(Interpol::Configuration.default)
    #end

    #it 'yields the configuration instance if a block is given' do
      #yielded1 = nil
      #Interpol.default_configuration { |c| yielded1 = c }
      #expect(yielded1).to be(Interpol.default_configuration)

      #yielded2 = nil
      #Interpol.default_configuration { |c| yielded2 = c }
      #expect(yielded2).to be(Interpol.default_configuration)
    #end
  #end
#end
  def test_default_configuration
    assert_equal(Heroics.default_configuration.class, Heroics::Configuration)
  end

  def yields_configuration_if_block_given
    yielded = nil

    Heroics.default_configuration { |c| yielded = c }

    assert_equal(yielded, Heroics.default_configuration)
  end
end
