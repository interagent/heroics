class Heroics

  def collaborators(app_identity)
    Heroics::Collaborators.new(self, app_identity: app_identity)
  end

  def collaborator(app_identity, collaborator_identity)
    Heroics::Collaborator.new(self.collaborators(app_identity), identity: collaborator_identity)
  end

  class App < Heroics::Resource

    def collaborators
      self.heroics.collaborators(identity)
    end

  end

  class Collaborators < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => "/apps/#{resource_proxy.app_identity}/collaborators"
      )
      Heroics::Collaborator.new(resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{resource_proxy.app_identity}/collaborators"
      )
      response.body.map do |attributes|
        Heroics::Collaborator.new(resource_proxy, attributes)
      end
    end

    def info(collaborator_identity)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{resource_proxy.app_identity}/collaborators/#{collaborator_identity}"
      )
      Heroics::Collaborator.new(resource_proxy, response.body)
    end

    def app_identity
      attributes[:app_identity]
    end

  end

  class Collaborator < Heroics::Resource

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{resource_proxy.app_identity}/collaborators/#{identity}"
      )
      Heroics::Collaborator.new(resource_proxy, response.body)
    end

    def identity
      attributes[:identity] || attributes[:id] || attributes[:user][:email]
    end

  end

end
