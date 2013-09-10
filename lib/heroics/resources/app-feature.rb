class Heroics

  def app-features(app_identity)
    Heroics::App-features.new(self, 'app_identity' => app_identity)
  end

  def app-feature(app_identity, identity)
    Heroics::App-feature.new(self.app-features(app_identity), 'identity' => identity)
  end

  class App < Heroics::Resource

    def app-features
      self.heroics.app-features(identity)
    end

  end

  class App-features < Heroics::ResourceProxy

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/features/#{identity}"
      )
      Heroics::App-feature.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/features"
      )
      response.body.map do |attributes|
        Heroics::App-feature.new(self.resource_proxy, attributes)
      end
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class App-feature < Heroics::Resource

    def updated(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/apps/#{resource_proxy.app_identity}/features/#{identity}"
      )
      Heroics::App-feature.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id'] || attributes['name']
    end

    def created_at
      attributes['created_at']
    end
    def description
      attributes['description']
    end
    def doc_url
      attributes['doc_url']
    end
    def enabled
      attributes['enabled']
    end
    def id
      attributes['id']
    end
    def name
      attributes['name']
    end
    def updated_at
      attributes['updated_at']
    end
  end

end
