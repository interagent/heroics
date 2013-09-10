class Heroics

  def keys
    Heroics::Keys.new(self)
  end

  def key(identity)
    Heroics::Key.new(self.keys, 'identity' => identity)
  end

  class Keys < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/account/keys"
      )
      Heroics::Key.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/account/keys/#{identity}"
      )
      Heroics::Key.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/account/keys/#{identity}"
      )
      response.body.map do |attributes|
        Heroics::Key.new(self.resource_proxy, attributes)
      end
    end

  end

  class Key < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/account/keys/#{identity}"
      )
      Heroics::Key.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id'] || attributes['fingerprint']
    end

    def created_at
      attributes['created_at']
    end
    def email
      attributes['email']
    end
    def fingerprint
      attributes['fingerprint']
    end
    def id
      attributes['id']
    end
    def public_key
      attributes['public_key']
    end
    def updated_at
      attributes['updated_at']
    end
  end

end
