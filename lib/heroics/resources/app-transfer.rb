# WARNING: generated code from heroku/heroics

class Heroics

  def app-transfers
    Heroics::App-transfers.new(self)
  end

  def app-transfer(identity)
    Heroics::App-transfer.new(self.app-transfers, 'identity' => identity)
  end

  class App-transfers < Heroics::ResourceProxy

    def create(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :post,
        path:   "/account/app-transfers"
      )
      Heroics::App-transfer.new(self.resource_proxy, response.body)
    end

    def info(identity)
      response = self.heroics.request(
        method: :get,
        path:   "/account/app-transfers/#{identity}"
      )
      Heroics::App-transfer.new(self.resource_proxy, response.body)
    end

    def list
      response = self.heroics.request(
        method: :get,
        path:   "/account/app-transfers"
      )
      response.body.map do |attributes|
        Heroics::App-transfer.new(self.resource_proxy, attributes)
      end
    end

  end

  class App-transfer < Heroics::Resource

    def delete
      response = self.heroics.request(
        method: :delete,
        path:   "/account/app-transfers/#{identity}"
      )
      Heroics::App-transfer.new(self.resource_proxy, response.body)
    end

    def update(new_attributes={})
      response = self.heroics.request(
        body:   MultiJson.dump(new_attributes),
        method: :patch,
        path:   "/account/app-transfers/#{identity}"
      )
      Heroics::App-transfer.new(self.resource_proxy, response.body)
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
