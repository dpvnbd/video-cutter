module ApiKeyAuthorization
  def authenticate_user!
    return if current_user

    render status: :unauthorized, json: {errors: [I18n.t(:unauthenticated)]}
  end

  def current_user
    api_key = request.headers["X-Api-Key"]
    User.find_by(api_key: api_key)
  end
end