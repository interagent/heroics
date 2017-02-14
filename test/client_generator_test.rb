# frozen_string_literal: true
require 'helper'
require 'netrc'
require 'stringio'

class GenerateClientTest  < MiniTest::Unit::TestCase
  include ExconHelper

  # generate_client takes a module, schema, API URL and options and returns a
  # string containing generated Ruby client code.
  def test_generate_client
    Excon.stub(method: :get) do |request|
      assert_equal('example.com', request[:host])
      assert_equal('/schema', request[:path])
      assert_equal('application/vnd.example+json; version=3',
                   request[:headers]['Accept'])
      Excon.stubs.pop
      {status: 200, headers: {'Content-Type' => 'application/json'},
       body: MultiJson.dump(SAMPLE_SCHEMA)}
    end

    default_headers =  {'Accept' => 'application/vnd.example+json; version=3'}

    netrc = Netrc.read
    username, token = netrc['example.com']
    schema_url = "https://example.com/schema"
    options = {
      default_headers: default_headers
    }

    schema = Heroics.download_schema(schema_url, options)

    Heroics.default_configuration do |config|
      config.base_url = 'api.example.com'
      config.module_name = 'ExampleAPI'
      config.schema = schema

      config.cache_path = "#{Dir.home}/.heroics/example"
      config.headers = default_headers
    end

    client_source = Heroics.generate_client

    # Ensure the generated code is syntactically valid.
    eval(client_source)
  end
end
