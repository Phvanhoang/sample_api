class MicropostsController < ApplicationController
  load_and_authorize_resource

  def create
    @micropost = current_user.microposts.build micropost_params
    return render_invalid_micropost unless @micropost.save

    render json: {messages: I18n.t("microposts.created")}, status: :created
  end

  def destroy
    @micropost.destroy!
    render json: {success: true}, status: :ok
  rescue ActiveRecord::RecordNotDestroyed
    render json: {success: false,
                  errors: I18n.t("microposts.delete_fail", id: @micropost.id)},
           status: :internal_server_error
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end

  def render_invalid_micropost
    render json: {errors: @micropost.errors}, status: :unprocessable_entity
  end
end
