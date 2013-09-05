class Heroics

  def apps
    Heroics::Apps.new(self)
  end

  def app(identity)
    Heroics::App.new(self.apps, :identity => identity)
  end

  class Apps < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => '/apps'
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => '/apps'
      )
      response.body.map {|attributes|
        Heroics::App.new(self.resource_proxy, attributes)
      }
    end

    def info(app_identity)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{app_identity}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

  end

  class App < Heroics::Resource

    def update(new_attributes)
      response = self.heroics.request(
        :method => :patch,
        :path   => "/apps/#{identity}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{identity}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    private

    def identity
      attributes[:identity] || attributes[:id] || attributes[:name]
    end

  end

end
