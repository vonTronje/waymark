class Character < ApplicationRecord
  include Shareable
  include Linkable

  has_one_attached :image

  validates :name, :level, :character_class, :species, presence: true
end
