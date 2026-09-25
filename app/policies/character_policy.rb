class CharacterPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    access?(:viewer)
  end

  def create?
    user.present?
  end

  def update?
    access?(:editor)
  end

  def destroy?
    access?(:owner)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.accessible_to(user)
    end
  end
end
