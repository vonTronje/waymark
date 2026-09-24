class Entry < ApplicationRecord
  include Authorizable

  has_rich_text :description

  validates :title, presence: true
end
