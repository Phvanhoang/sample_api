class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do
    render json: {messages: I18n.t("unauthorized.message")},
           status: :unauthorized
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {errors: exception},
           status: :not_found
  end

  def authenticate_user!
    return if current_user

    render json: {messages: I18n.t(".invalid_token")},
           status: :unauthorized
  end

  def current_user
    token = JWT.decode(request.headers["AUTH-TOKEN"], ENV["API_SECURE_KEY"],
                       true, algorithm: Settings.algorithm)
    User.find_by auth_token: token.first["auth_token"]
  rescue JWT::DecodeError, JWT::VerificationError
    false
  end
end
