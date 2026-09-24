module Authorizable
  extend ActiveSupport::Concern

  included do
    has_many :shares, as: :shareable, dependent: :destroy
    after_create :grant_owner_share
  end

  def accessible_to?(user, as: :viewer)
    return true if user&.admin?

    shares.where(user: user).merge(Share.for_access(as)).exists?
  end

  def access_for(user)
    shares.find_by(user: user)&.access
  end

  def non_owner_access
    shares.non_owner
  end

  class_methods do
    def accessible_to(user, as: :viewer)
      return all if user.admin?

      left_joins(:shares).where(shares: { user_id: user.id }).merge(Share.for_access(as)).distinct
    end
  end

  private
    def grant_owner_share
      return unless Current.user

      shares.create!(user: Current.user, access: :owner)
    end
end
