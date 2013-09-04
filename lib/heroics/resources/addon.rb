class Heroics

  def addons(app_id_or_name)
    Heroics::Addons.new(self, app_id_or_name)
  end

  def addon(app_id_or_name, attributes={})
    Heroics::Addon.new(self, app_id_or_name, attributes={})
  end

  class App < Heroics::Resource

    def addons
      Heroics::Addons.new(self.heroics, :app_id_or_name => id_or_name)
    end

  end

  class Addons < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => "/apps/#{self.attributes[:app_id_or_name]}/addons"
      )
      Heroics::Addon.new(self, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{self.attributes[:app_id_or_name]}/addons"
      )
      response.body.map {|resource_attributes|
        Heroics::Addon.new(self, resource_attributes)
      }
    end

    def info(addon_id_or_name)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{self.attributes[:app_id_or_name]}/addons/#{addon_id_or_name}"
      )
      Heroics::Addon.new(self, response.body)
    end

  end

  class Addon < Heroics::Resource

    def update(new_attributes)
      response = self.heroics.request(
        :method => :patch,
        :path   => "/apps/#{self.resource_proxy.attributes[:app_id_or_name]}/addons/#{id_or_name}"
      )
      Heroics::Addon.new(self.resource_proxy, response.body)
    end

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{self.resource_proxy.attributes[:app_id_or_name]}/addons/#{id_or_name}"
      )
      Heroics::Addon.new(self.resource_proxy, response.body)
    end

    private

    def id_or_name
      attributes[:id] || attributes[:name]
    end

  end

end
