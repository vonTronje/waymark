class Link < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true

  enum :link_type, { mention: "mention", author: "author", owner: "owner" }

  validates :link_type, presence: true
  validate :source_must_be_linkable
  validate :target_must_be_linkable
  validate :source_and_target_must_differ

  scope :involving, ->(record) {
    where(source: record).or(where(target: record))
  }

  private
    def source_must_be_linkable
      return if source.nil?
      return if Linkable.registry.include?(source.class)

      errors.add(:source, "must be a linkable type")
    end

    def target_must_be_linkable
      return if target.nil?
      return if Linkable.registry.include?(target.class)

      errors.add(:target, "must be a linkable type")
    end

    def source_and_target_must_differ
      return if source.nil? || target.nil?
      return unless source == target

      errors.add(:target, "must be different from source")
    end
end
