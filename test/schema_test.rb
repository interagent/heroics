require 'helper'

class DownloadSchemaTest < MiniTest::Test
  # download_schema makes a request to fetch the schema, decodes the
  # downloaded JSON and returns a Ruby hash.
  def test_download_schema
    Excon.stub(method: :get) do |request|
      assert_equal('example.com', request[:host])
      assert_equal('/schema', request[:path])
      assert_equal('application/vnd.heroku+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(SAMPLE_SCHEMA)}
    end

    schema = Heroics::download_schema(
      'https://username:token@example.com/schema',
      default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'})
    assert_equal(SAMPLE_SCHEMA, schema)
  end
end
