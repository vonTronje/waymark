class Entry < ApplicationRecord
  include Shareable
  include Linkable

  has_rich_text :description

  validates :title, presence: true
end
