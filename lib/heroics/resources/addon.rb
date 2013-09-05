class Heroics

  def addons(app_identity)
    Heroics::Addons.new(self, :app_identity => app_identity)
  end

  def addon(app_identity, addon_identity)
    Heroics::Addon.new(self.addons(:app_identity => app_identity), :identity => addon_identity)
  end

  class App < Heroics::Resource

    def addons
      Heroics::Addons.new(self.heroics, :app_identity => identity)
    end

  end

  class Addons < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => "/apps/#{self.attributes[:app_identity]}/addons"
      )
      Heroics::Addon.new(resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{self.attributes[:app_identity]}/addons"
      )
      response.body.map {|resource_attributes|
        Heroics::Addon.new(resource_proxy, resource_attributes)
      }
    end

    def info(addon_identity)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{self.attributes[:app_identity]}/addons/#{addon_identity}"
      )
      Heroics::Addon.new(resource_proxy, response.body)
    end

  end

  class Addon < Heroics::Resource

    def update(new_attributes)
      response = self.heroics.request(
        :method => :patch,
        :path   => "/apps/#{resource_proxy.attributes[:app_identity]}/addons/#{identity}"
      )
      Heroics::Addon.new(resource_proxy, response.body)
    end

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{resource_proxy.attributes[:app_identity]}/addons/#{identity}"
      )
      Heroics::Addon.new(resource_proxy, response.body)
    end

    private

    def identity
      attributes[:identity] || attributes[:id] || attributes[:name]
    end

  end

end
