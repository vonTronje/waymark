module Linkable
  extend ActiveSupport::Concern

  mattr_accessor :registry, default: []

  included do
    has_many :outgoing_links, as: :source, class_name: "Link", dependent: :destroy
    has_many :incoming_links, as: :target, class_name: "Link", dependent: :destroy

    Linkable.register(self)
  end

  def self.register(klass)
    registry << klass unless registry.include?(klass)
  end

  def links
    Link.involving(self)
  end
end
