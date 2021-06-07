class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  load_and_authorize_resource

  def create
    @user = User.new user_params
    if @user.save
      render json: {messages: I18n.t("users.created")},
             status: :created
    else
      render_invalid_user
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name,
                                 :password, :password_confirmation)
  end

  def render_invalid_user
    render json: {errors: @user.errors}, status: :unprocessable_entity
  end
end
