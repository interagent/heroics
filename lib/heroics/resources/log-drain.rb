class Heroics

  def log-drains(app_identity)
    Heroics::Log-drains.new(self, 'app_identity' => app_identity)
  end

  def log-drain(app_identity, identity)
    Heroics::Log-drain.new(self.log-drains(app_identity), 'identity' => identity)
  end

  class App < Heroics::Resource

    def log-drains
      self.heroics.log-drains(identity)
    end

  end

  class Log-drains < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps/#{resource_proxy.app_identity}/log-drains"
      )
      Heroics::Log-drain.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/log-drains/#{identity}"
      )
      Heroics::Log-drain.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/log-drainds/#{identity}"
      )
      response.body.map do |attributes|
        Heroics::Log-drain.new(self.resource_proxy, attributes)
      end
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class Log-drain < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/apps/#{resource_proxy.app_identity}/log-drains/#{identity}"
      )
      Heroics::Log-drain.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id'] || attributes['url']
    end

    def addon
      attributes['addon']
    end
    def created_at
      attributes['created_at']
    end
    def id
      attributes['id']
    end
    def updated_at
      attributes['updated_at']
    end
    def url
      attributes['url']
    end
  end

end
