class ApplicationController < ActionController::API
  before_action :authenticate_user!

  def authenticate_user!
    return if current_user

    render json: {messages: I18n.t(".invalid_token")},
           status: :unauthorized
  end

  def current_user
    token = JWT.decode(request.headers["AUTH-TOKEN"], ENV["API_SECURE_KEY"],
                       true, algorithm: Settings.algorithm)
    @user = User.find_by auth_token: token.first
  rescue JWT::DecodeError, JWT::VerificationError
    false
  end
end
