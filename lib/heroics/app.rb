class Heroics
  class Apps

    attr_accessor :heroics

    def initialize(new_heroics)
      self.heroics = new_heroics
    end

    def inspect
      "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
    end

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => '/apps'
      )
      Heroics::App.new(self.heroics, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => '/apps'
      )
      response.body.map {|attributes|
        Heroics::App.new(self.heroics, attributes)
      }
    end

    def info(app_id_or_name)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{app_id_or_name}"
      )
      Heroics::App.new(self.heroics, response.body)
    end

  end

  class App

    attr_accessor :attributes, :heroics

    def initialize(new_heroics, new_attributes={})
      self.heroics, self.attributes = new_heroics, new_attributes
    end

    def inspect
      "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)} #{attributes.inspect}>"
    end

    def update(new_attributes)
      response = self.heroics.request(
        :method => :patch,
        :path   => "/apps/#{id_or_name}"
      )
      Heroics::App.new(self.heroics, response.body)
    end

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{id_or_name}"
      )
      Heroics::App.new(self.heroics, response.body)
    end

    def addons
      Heroics::Addons.new(self.heroics, id_or_name)
    end

    private

    def id_or_name
      attributes[:id] || attributes[:name]
    end

  end

end
