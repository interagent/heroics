# WARNING: generated code from heroku/heroics

class Heroics

  def app_transfers(identity=nil)
    if identity
      Heroics::AppTransfer.new(self.app_transfers, 'identity' => identity)
    else
      Heroics::AppTransfers.new(self)
    end
  end

  class AppTransfers < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/account/app-transfers"
      )
      Heroics::AppTransfer.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/account/app-transfers/#{identity}"
      )
      Heroics::AppTransfer.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/account/app-transfers"
      )
      response.body.map do |attributes|
        Heroics::AppTransfer.new(self.resource_proxy, attributes)
      end
    end

  end

  class AppTransfer < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/account/app-transfers/#{identity}"
      )
      Heroics::AppTransfer.new(self.resource_proxy, response.body)
    end

    def update(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/account/app-transfers/#{identity}"
      )
      Heroics::AppTransfer.new(self.resource_proxy, response.body)
    end

    def identity
      attributes['identity'] || attributes['id']
    end

    def app
      attributes['app']
    end
    def created_at
      attributes['created_at']
    end
    def id
      attributes['id']
    end
    def owner
      attributes['owner']
    end
    def recipient
      attributes['recipient']
    end
    def state
      attributes['state']
    end
    def updated_at
      attributes['updated_at']
    end
  end

end
