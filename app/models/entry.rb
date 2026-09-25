class Entry < ApplicationRecord
  include Shareable

  has_rich_text :description

  validates :title, presence: true
end
