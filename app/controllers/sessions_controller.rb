class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  before_action :load_user

  def create
    if @user.authenticate session_params[:password]
      render json: {auth_token: @user.generate_new_encoded_token,
                    messages: I18n.t("sessions.logged_in")}, status: :ok
    else
      render_invalid_user
    end
  end

  private

  def load_user
    @user = User.find_by email: session_params[:email]
    return if @user

    render_invalid_user
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def render_invalid_user
    render json: {messages: I18n.t("sessions.invalid")}, status: :unauthorized
  end
end
