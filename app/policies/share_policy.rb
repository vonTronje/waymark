class SharePolicy < ApplicationPolicy
  def create?
    admin_or_owner?
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    admin_or_owner?
  end

  private
    def admin_or_owner?
      admin? || record.shareable.accessible_to?(user, as: :owner)
    end
end
