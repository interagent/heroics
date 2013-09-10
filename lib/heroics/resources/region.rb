# WARNING: generated code from heroku/heroics

class Heroics

  def regions
    Heroics::Regions.new(self)
  end

  def region(identity)
    Heroics::Region.new(self.regions, 'identity' => identity)
  end

  class Regions < Heroics::ResourceProxy

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/regions/#{identity}"
      )
      Heroics::Region.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/regions"
      )
      response.body.map do |attributes|
        Heroics::Region.new(self.resource_proxy, attributes)
      end
    end

  end

  class Region < Heroics::Resource

    def identity
      attributes['identity'] || attributes['id'] || attributes['name']
    end

    def created_at
      attributes['created_at']
    end
    def description
      attributes['description']
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
