# WARNING: generated code from heroku/heroics

class Heroics

  def log-sessions(app_identity)
    Heroics::Log-sessions.new(self, 'app_identity' => app_identity)
  end

  def log-session(app_identity, identity)
    Heroics::Log-session.new(self.log-sessions(app_identity), 'identity' => identity)
  end

  class App < Heroics::Resource

    def log-sessions
      self.heroics.log-sessions(identity)
    end

  end

  class Log-sessions < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps/#{resource_proxy.app_identity}/log-sessions"
      )
      Heroics::Log-session.new(self.resource_proxy, response.body)
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class Log-session < Heroics::Resource

    def identity
      attributes['identity'] || attributes['id']
    end

    def created_at
      attributes['created_at']
    end
    def id
      attributes['id']
    end
    def logplex_url
      attributes['logplex_url']
    end
    def updated_at
      attributes['updated_at']
    end
  end

end
