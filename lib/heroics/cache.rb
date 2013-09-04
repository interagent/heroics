class Heroics
  class Cache

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
end
