# WARNING: generated code from heroku/heroics

class Heroics

  class App < Heroics::Resource

    def log_drains
      Heroics::LogDrains.new(self.heroics, 'app_identity' => identity)
    end

  end

  class LogDrains < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps/#{resource_proxy.app_identity}/log-drains"
      )
      Heroics::LogDrain.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/log-drains/#{identity}"
      )
      Heroics::LogDrain.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/log-drainds/#{identity}"
      )
      response.body.map do |attributes|
        Heroics::LogDrain.new(self.resource_proxy, attributes)
      end
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class LogDrain < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/apps/#{resource_proxy.app_identity}/log-drains/#{identity}"
      )
      Heroics::LogDrain.new(self.resource_proxy, response.body)
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
