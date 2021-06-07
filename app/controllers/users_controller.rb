class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  load_and_authorize_resource

  def index
    @paged_users = @users.paginate(page: params[:page]).per_page Settings.page
    @serial_users = ActiveModel::Serializer::CollectionSerializer
                    .new(@paged_users, serializer: UserSerializer)
    render json: {users: @serial_users, count: @serial_users.count,
                  total_pages: @paged_users.total_pages}, status: :ok
  end

  def show
    @microposts = @user.microposts.paginate(page: params[:page])
                       .per_page(Settings.page)
    render json: {user: UserSerializer.new(@user), microposts: @microposts,
                  count: @microposts.size,
                  total_pages: @microposts.total_pages}, status: :ok
  end

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
    if @user&.authenticate user_update_params[:current_password]
      if @user.update user_update_params.except(:current_password)
        render json: {messages: I18n.t("users.updated")}, status: :ok
      else
        render_invalid_user
      end
    else
      render json: {errors: I18n.t("users.wrong_password")},
             status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private

  def user_params
    params.require(:user).permit(:email, :name,
                                 :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:email, :name, :current_password,
                                 :password, :password_confirmation)
  end

  def render_invalid_user
    render json: {errors: @user.errors}, status: :unprocessable_entity
  end
end
