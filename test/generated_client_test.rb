require 'helper'
require 'netrc'
require 'stringio'



class GeneratedClientTest  < MiniTest::Unit::TestCase

  def test_api_generation
    netrc = Netrc.read
    username, token = netrc['api.heroku.com']
    schema_url = "https://:#{token}@api.heroku.com/schema"
    options = {
        default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'},
        cache: 'Moneta.new(:File, dir: "#{Dir.home}/.heroics/platform-api")'
    }
    schema = Heroics.download_schema(schema_url, options)
    client_source = Heroics.generate_client("PlatformApi", schema, "api.heroku.com", options)
    begin
     client = eval(client_source)
    rescue
      puts client_source
    end
  end
end