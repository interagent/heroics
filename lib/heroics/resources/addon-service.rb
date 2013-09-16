# WARNING: generated code from heroku/heroics

class Heroics

  def addon-services(identity=nil)
    if identity
      Heroics::Addon-service.new(self.addon-services, 'identity' => identity)
    else
      Heroics::Addon-services.new(self)
    end
  end

  class Addon-services < Heroics::ResourceProxy

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/addon-services/#{identity}"
      )
      Heroics::Addon-service.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/addon-services"
      )
      response.body.map do |attributes|
        Heroics::Addon-service.new(self.resource_proxy, attributes)
      end
    end

  end

  class Addon-service < Heroics::Resource

    def identity
      attributes['identity'] || attributes['id'] || attributes['name']
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
    def updated_at
      attributes['updated_at']
    end
  end

end
