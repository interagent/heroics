class Heroics

  def apps
    Heroics::Apps.new(self)
  end

  def app(identity)
    Heroics::App.new(self.apps, 'identity' => identity)
  end

  class Apps < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{identity}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/apps"
      )
      response.body.map do |attributes|
        Heroics::App.new(self.resource_proxy, attributes)
      end
    end

  end

  class App < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/apps/#{identity}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def update(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/apps/#{identity}"
      )
      Heroics::App.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id'] || attributes['name']
    end

    def archived_at
      attributes['archived_at']
    end
    def buildpack_provided_description
      attributes['buildpack_provided_description']
    end
    def created_at
      attributes['created_at']
    end
    def git_url
      attributes['git_url']
    end
    def id
      attributes['id']
    end
    def maintenance
      attributes['maintenance']
    end
    def name
      attributes['name']
    end
    def owner
      attributes['owner']
    end
    def region
      attributes['region']
    end
    def released_at
      attributes['released_at']
    end
    def repo_size
      attributes['repo_size']
    end
    def slug_size
      attributes['slug_size']
    end
    def stack
      attributes['stack']
    end
    def updated_at
      attributes['updated_at']
    end
    def web_url
      attributes['web_url']
    end
  end

end
