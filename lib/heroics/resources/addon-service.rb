# WARNING: generated code from heroku/heroics

class Heroics

  def addon_services(identity=nil)
    if identity
      Heroics::AddonService.new(self.addon_services, 'identity' => identity)
    else
      Heroics::AddonServices.new(self)
    end
  end

  class AddonServices < Heroics::ResourceProxy

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/addon-services/#{identity}"
      )
      Heroics::AddonService.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/addon-services"
      )
      response.body.map do |attributes|
        Heroics::AddonService.new(self.resource_proxy, attributes)
      end
    end

  end

  class AddonService < Heroics::Resource

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
