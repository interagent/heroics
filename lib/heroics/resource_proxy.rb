class Heroics
  class ResourceProxy

    attr_accessor :attributes, :heroics

    def initialize(new_heroics, new_attributes={})
      self.heroics, self.attributes  = new_heroics, new_attributes
    end

    alias :inspect :to_s

    def resource_proxy
      self
    end

    def to_s
      "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
    end

  end
end
