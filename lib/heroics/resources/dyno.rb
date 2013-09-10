# WARNING: generated code from heroku/heroics

class Heroics

  def dynos(app_identity)
    Heroics::Dynos.new(self, 'app_identity' => app_identity)
  end

  def dyno(app_identity, identity)
    Heroics::Dyno.new(self.dynos(app_identity), 'identity' => identity)
  end

  class App < Heroics::Resource

    def dynos
      self.heroics.dynos(identity)
    end

  end

  class Dynos < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps/#{resource_proxy.app_identity}/dynos"
      )
      Heroics::Dyno.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/dynos/#{identity}"
      )
      Heroics::Dyno.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/dynos/#{identity}"
      )
      response.body.map do |attributes|
        Heroics::Dyno.new(self.resource_proxy, attributes)
      end
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class Dyno < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/apps/#{resource_proxy.app_identity}/dynos/#{identity}"
      )
      Heroics::Dyno.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id'] || attributes['name']
    end

    def attach
      attributes['attach']
    end
    def attach_url
      attributes['attach_url']
    end
    def command
      attributes['command']
    end
    def created_at
      attributes['created_at']
    end
    def id
      attributes['id']
    end
    def name
      attributes['name']
    end
    def release
      attributes['release']
    end
    def size
      attributes['size']
    end
    def state
      attributes['state']
    end
    def type
      attributes['type']
    end
    def updated_at
      attributes['updated_at']
    end
  end

end
