require('json')
require('zlib')

require('excon')

require('./lib/heroics/cache')
require('./lib/heroics/resource')
require('./lib/heroics/resource_proxy')
require('./lib/heroics/version')

directory = File.expand_path(File.dirname(__FILE__))
Dir.glob(File.join(directory, 'heroics', 'resources', '**', '*')).each do |path|
  unless File.directory?(path)
    require(path)
  end
end

class Heroics

  HEADERS =  {
    'Accept'          => 'application/vnd.heroku+json; version=3',
    'Accept-Encoding' => 'gzip',
    'Content-Type'    => 'application/json',
    'User-Agent'      => 'heroics/' << Heroics::VERSION
  }

  def initialize(options={})
    @token = options[:token]

    # should be something with API like https://github.com/minad/moneta
    # in particular, expects key?, [], []=
    @cache = options[:cache] || Heroics::Cache.new

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

    if data[:method] == :get
      if @cache.key?("etag:#{data[:path]}")
        data[:headers] ||= {}
        data[:headers]['If-None-Match'] = @cache["etag:#{data[:path]}"]
      end
    end

    response = @connection.request(data)

    if response.status == 304
      response = Excon::Response.new(@cache["data:#{data[:path]}"])
    else
      if response.headers['Content-Encoding'] == 'gzip'
        response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
      end

      if response.body && !response.body.empty?
        response.body = JSON.parse(response.body, :symbolize_names => true)
      end

      if data[:method] == :get
        @cache["data:#{data[:path]}"] = response.data
        @cache["etag:#{data[:path]}"] = response.headers['ETag']
      end
    end

    response
  end

end
