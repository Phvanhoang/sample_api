class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  load_and_authorize_resource
  before_action :correct_password, only: :update

  def create
    @user = User.new user_params
    if @user.save
      render json: {messages: I18n.t("users.created")},
             status: :created
    else
      render_invalid_user
    end
  end

  def update
    if @user.update user_update_params.except(:current_password)
      render json: {messages: I18n.t("users.updated")}, status: :ok
    else
      render_invalid_user
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name,
                                 :password, :password_confirmation)
  end

  def correct_password
    return if @user&.authenticate user_update_params[:current_password]

    render json: {errors: I18n.t("users.wrong_password")},
            status: :unprocessable_entity
  end

  def user_update_params
    params.require(:user).permit(:email, :name, :current_password,
                                 :password, :password_confirmation)
  end

  def render_invalid_user
    render json: {errors: @user.errors}, status: :unprocessable_entity
  end
end
