class Heroics
  class MemoryCache

    def initialize
      @data = {}
    end

    def key?(key)
      @data.has_key?(key)
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

  end

  class FileCache < MemoryCache

    def initialize(token)
      require 'fileutils'
      @path = File.expand_path("~/.heroku/cache/#{token}")
      FileUtils.mkdir_p(File.dirname(@path))

      @data = if File.exists?(@path)
        MultiJson.load(File.read(@path))
      else
        {}
      end
    end

    def []=(key, value)
      result = super
      File.open(@path, 'w') do |file|
        file.puts(MultiJson.dump(@data))
      end
      result
    end

  end

end
