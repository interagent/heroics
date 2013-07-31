require('json')
require('zlib')

require('excon')

require('heroics/addon')
require('heroics/app')
require('heroics/version')

class Heroics

  HEADERS =  {
    'Accept'          => 'application/vnd.heroku+json; version=3',
    'Accept-Encoding' => 'gzip',
    'Content-Type'    => 'application/json',
    'User-Agent'      => 'heroics/' << Heroics::VERSION
  }

  def initialize(options={})
    @token = options[:token]
    @connection = Excon.new(
      'https://api.heroku.com',
      :headers => HEADERS.merge({
        "Authorization" => "Basic #{[':' << @token].pack('m').delete("\r\n")}"
      })
    )
  end

  def inspect
    "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
  end

  def request(data={})
    @connection.reset
    response = @connection.request(data)

    if response.headers['Content-Encoding'] == 'gzip'
      response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
    end

    if response.body && !response.body.empty?
      response.body = JSON.parse(response.body, :symbolize_names => true)
    end

    response
  end

  def addons(app_id_or_name)
    Heroics::Addons.new(self, app_id_or_name)
  end
  def addon(app_id_or_name, attributes={})
    Heroics::Addon.new(self, app_id_or_name, attributes={})
  end

  def apps
    Heroics::Apps.new(self)
  end
  def app(attributes={})
    Heroics::App.new(self, attributes)
  end

end
