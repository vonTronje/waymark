class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def share?
    record.is_a?(Shareable) && access?(:owner)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private
      attr_reader :user, :scope
  end

  private
    def admin?
      user&.admin?
    end

    def access?(level)
      admin? || record.accessible_to?(user, as: level)
    end
end
