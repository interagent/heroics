# WARNING: generated code from heroku/heroics

class Heroics

  def domains(app_identity)
    Heroics::Domains.new(self, 'app_identity' => app_identity)
  end

  def domain(app_identity, identity)
    Heroics::Domain.new(self.domains(app_identity), 'identity' => identity)
  end

  class App < Heroics::Resource

    def domains
      self.heroics.domains(identity)
    end

  end

  class Domains < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps/#{resource_proxy.app_identity}/domains"
      )
      Heroics::Domain.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/domains/#{identity}"
      )
      Heroics::Domain.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/apps/#{resource_proxy.app_identity}/domains"
      )
      response.body.map do |attributes|
        Heroics::Domain.new(self.resource_proxy, attributes)
      end
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class Domain < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/apps/#{resource_proxy.app_identity}/domains/#{identity}"
      )
      Heroics::Domain.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id'] || attributes['hostname']
    end

    def created_at
      attributes['created_at']
    end
    def hostname
      attributes['hostname']
    end
    def id
      attributes['id']
    end
    def updated_at
      attributes['updated_at']
    end
  end

end
