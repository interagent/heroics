# WARNING: generated code from heroku/heroics

class Heroics

  class App < Heroics::Resource

    def log_sessions
      Heroics::LogSessions.new(self.heroics, 'app_identity' => identity)
    end

  end

  class LogSessions < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/apps/#{resource_proxy.app_identity}/log-sessions"
      )
      Heroics::LogSession.new(self.resource_proxy, response.body)
    end

    def app_identity
      attributes['app_identity']
    end

  end

  class LogSession < Heroics::Resource

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
