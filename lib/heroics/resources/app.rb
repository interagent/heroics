class Heroics

  def apps
    Heroics::Apps.new(self)
  end

  def app(attributes={})
    Heroics::App.new(self, attributes)
  end

  class Apps < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => '/apps'
      )
      Heroics::App.new(self, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => '/apps'
      )
      response.body.map {|attributes|
        Heroics::App.new(self, attributes)
      }
    end

    def info(app_id_or_name)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{app_id_or_name}"
      )
      Heroics::App.new(self, response.body)
    end

  end

  class App < Heroics::Resource

    def update(new_attributes)
      response = self.heroics.request(
        :method => :patch,
        :path   => "/apps/#{id_or_name}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{id_or_name}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    private

    def id_or_name
      attributes[:id] || attributes[:name]
    end

  end

end
