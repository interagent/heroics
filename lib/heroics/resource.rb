class Heroics
  class Resource

    attr_accessor :attributes, :resource_proxy

    def initialize(new_resource_proxy, new_attributes={})
      self.resource_proxy, self.attributes = new_resource_proxy, new_attributes
    end

    def heroics
      self.resource_proxy.heroics
    end

    alias :inspect :to_s

    def to_s
      "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)} #{self.attributes.inspect}>"
    end

  end
end
