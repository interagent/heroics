# WARNING: generated code from heroku/heroics

class Heroics

  def accounts(identity=nil)
    if identity
      Heroics::Account.new(self.accounts, 'identity' => identity)
    else
      Heroics::Accounts.new(self)
    end
  end

  class Accounts < Heroics::ResourceProxy

    def info
      response = self.heroics.request(
        method: :get,
        path:   "/account"
      )
      Heroics::Account.new(self.resource_proxy, response.body)
    end

  end

  class Account < Heroics::Resource

    def update(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/account"
      )
      Heroics::Account.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['email'] || attributes['id']
    end

    def allow_tracking
      attributes['allow_tracking']
    end
    def beta
      attributes['beta']
    end
    def created_at
      attributes['created_at']
    end
    def email
      attributes['email']
    end
    def id
      attributes['id']
    end
    def last_login
      attributes['last_login']
    end
    def updated_at
      attributes['updated_at']
    end
    def verified
      attributes['verified']
    end
  end

end
