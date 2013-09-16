# WARNING: generated code from heroku/heroics

class Heroics

  def account_features(identity=nil)
    if identity
      Heroics::AccountFeature.new(self.account_features, 'identity' => identity)
    else
      Heroics::AccountFeatures.new(self)
    end
  end

  class AccountFeatures < Heroics::ResourceProxy

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/account/features/#{identity}"
      )
      Heroics::AccountFeature.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/account/features"
      )
      response.body.map do |attributes|
        Heroics::AccountFeature.new(self.resource_proxy, attributes)
      end
    end

  end

  class AccountFeature < Heroics::Resource

    def updated(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/account/features/#{identity}"
      )
      Heroics::AccountFeature.new(self.resource_proxy, response.body)
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
