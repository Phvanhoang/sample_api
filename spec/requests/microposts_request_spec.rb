require "rails_helper"

RSpec.describe "Microposts", type: :request do
  describe "POST #create" do
    let!(:user){ create(:user) }
    let!(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    it "has status unauthorized when invalid token" do
      post microposts_path
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t(".invalid_token")
    end

    it "has status unprocessable_entity when invalid micropost" do
      invalid_miropost = FactoryBot.attributes_for(:invalid_micropost)
      post microposts_path, params: {micropost: invalid_miropost} ,headers: headers
      expect(response).to have_http_status :unprocessable_entity
      expect(response.body).to include assigns(:micropost).errors.to_json
    end

    it "has status created when valid micropost" do
      miropost = FactoryBot.attributes_for(:micropost)
      post microposts_path, params: {micropost: miropost} ,headers: headers
      expect(response).to have_http_status :created
      expect(response.body).to include I18n.t("microposts.created")
    end
  end
end
