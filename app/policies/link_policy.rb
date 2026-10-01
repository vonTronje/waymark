class LinkPolicy < ApplicationPolicy
  def show?
    both_ends_viewer?
  end

  def create?
    both_ends_viewer?
  end

  def update?
    both_ends_viewer?
  end

  def destroy?
    both_ends_viewer?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?

      visible_ids = scope.filter_map do |link|
        link.id if both_ends_viewer?(link)
      end

      scope.where(id: visible_ids)
    end

    private
      def both_ends_viewer?(link)
        link.source.accessible_to?(user, as: :viewer) &&
          link.target.accessible_to?(user, as: :viewer)
      end
  end

  private
    def both_ends_viewer?
      return true if admin?

      record.source.accessible_to?(user, as: :viewer) &&
        record.target.accessible_to?(user, as: :viewer)
    end
end
