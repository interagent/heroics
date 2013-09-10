# WARNING: generated code from heroku/heroics

class Heroics

  def account-features
    Heroics::Account-features.new(self)
  end

  def account-feature(identity)
    Heroics::Account-feature.new(self.account-features, 'identity' => identity)
  end

  class Account-features < Heroics::ResourceProxy

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/account/features/#{identity}"
      )
      Heroics::Account-feature.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/account/features"
      )
      response.body.map do |attributes|
        Heroics::Account-feature.new(self.resource_proxy, attributes)
      end
    end

  end

  class Account-feature < Heroics::Resource

    def updated(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/account/features/#{identity}"
      )
      Heroics::Account-feature.new(self.resource_proxy, response.body)
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
