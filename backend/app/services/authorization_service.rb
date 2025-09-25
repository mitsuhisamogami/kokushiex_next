class AuthorizationService
  class UnauthorizedError < StandardError
    attr_reader :action, :required_role

    def initialize(message = "この操作を実行する権限がありません。", action: nil, required_role: nil)
      super(message)
      @action = action
      @required_role = required_role
    end
  end

  PERMISSIONS = {
    view_tests: [ :guest, :regular, :admin ],
    take_tests: [ :guest, :regular, :admin ],
    save_scores: [ :regular, :admin ],
    view_history: [ :regular, :admin ],
    edit_profile: [ :regular, :admin ],
    admin_features: [ :admin ]
  }.freeze

  ROLE_HIERARCHY = {
    guest: 0,
    regular: 1,
    admin: 2
  }.freeze

  def initialize(user)
    @user = user
  end

  def permit?(action, resource = nil)
    return false if @user.nil?
    return false unless PERMISSIONS.key?(action)

    allowed_roles = PERMISSIONS[action]
    user_role = @user.role.to_sym

    allowed_roles.include?(user_role)
  end

  def authorize!(action, resource = nil)
    if permit?(action, resource)
      true
    else
      raise UnauthorizedError.new(
        action: action,
        required_role: required_role_for(action)
      )
    end
  end

  def required_role_for(action)
    return nil unless PERMISSIONS.key?(action)

    allowed_roles = PERMISSIONS[action]
    allowed_roles.min_by { |role| role_hierarchy(role) }
  end

  private

  def role_hierarchy(role)
    ROLE_HIERARCHY[role] || Float::INFINITY
  end
end
