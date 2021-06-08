class RelationshipsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  before_action :followed_user_exist, only: :create

  def create
    if current_user.following? @user
      render json: {messages: I18n.t("relationships.followed_user_error")},
             status: :unprocessable_entity
    else
      current_user.follow(@user)
      render json: {messages: I18n.t("relationships.created")}, status: :created
    end
  end

  private

  def followed_user_exist
    @user = User.find_by id: params[:followed_id]
    return if @user

    render_not_found_user
  end

  def render_not_found_user
    render json: {errors: I18n.t("relationships.user_not_found")},
           status: :unprocessable_entity
  end
end
