class Share < ApplicationRecord
  belongs_to :user
  belongs_to :shareable, polymorphic: true

  enum :access, { viewer: "viewer", editor: "editor", owner: "owner" }

  validates :user_id, uniqueness: { scope: [ :shareable_type, :shareable_id ] }

  def self.for_access(level)
    case level.to_sym
    when :viewer then viewable
    when :editor then editable
    when :owner then owned
    else raise ArgumentError, "Unknown access level: #{level}"
    end
  end

  def self.viewable
    where(access: %w[ viewer editor owner ])
  end

  def self.editable
    where(access: %w[ editor owner ])
  end

  def self.owned
    where(access: "owner")
  end
end
