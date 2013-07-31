class Heroics
  class Addons

    attr_accessor :app_id_or_name, :heroics

    def initialize(new_heroics, new_app_id_or_name)
      self.app_id_or_name, self.heroics = new_app_id_or_name, new_heroics
    end

    def inspect
      "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
    end

    def create(new_attributes={})
      response = self.heroics.request(
        :body   => JSON.generate(new_attributes),
        :method => :post,
        :path   => "/apps/#{self.app_id_or_name}/addons"
      )
      Heroics::Addon.new(self.heroics, self.app_id_or_name, response.body)
    end

    def list
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{self.app_id_or_name}/addons"
      )
      response.body.map {|attributes|
        Heroics::Addon.new(self.heroics, self.app_id_or_name, attributes)
      }
    end

    def info(addon_id_or_name)
      response = self.heroics.request(
        :method => :get,
        :path   => "/apps/#{self.app_id_or_name}/addons/#{addon_id_or_name}"
      )
      Heroics::Addon.new(self.heroics, self.app_id_or_name, response.body)
    end

  end

  class Addon

    attr_accessor :app_id_or_name, :attributes, :heroics

    def initialize(new_heroics, new_app_id_or_name, new_attributes={})
      self.app_id_or_name, self.attributes, self.heroics = new_app_id_or_name, new_attributes, new_heroics
    end

    def inspect
      "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)} #{attributes.inspect}>"
    end

    def update(new_attributes)
      response = self.heroics.request(
        :method => :patch,
        :path   => "/apps/#{self.app_id_or_name}/addons/#{id_or_name}"
      )
      Heroics::Addon.new(self.heroics, response.body)
    end

    def delete
      response = self.heroics.request(
        :method => :delete,
        :path   => "/apps/#{self.app_id_or_name}/addons/#{id_or_name}"
      )
      Heroics::Addon.new(self.heroics, response.body)
    end

    private

    def id_or_name
      attributes[:id] || attributes[:name]
    end

  end

end
