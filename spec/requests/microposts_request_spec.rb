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

  describe "DELETE #destroy" do
    let!(:user){ create(:user_with_microposts) }
    let(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    it "has status unauthorized when invalid token" do
      delete micropost_path(user.microposts.first)
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t(".invalid_token")
    end

    it "has status not_found when user not found" do
      delete micropost_path(-1), headers: headers
      expect(response).to have_http_status :not_found
      expect(response.body).to include "Couldn't find Micropost with 'id'=-1"
    end

    it "has status unauthorized when user is not admin or not correct user" do
      other_user = create(:user)
      headers = {"AUTH-TOKEN": other_user.generate_new_encoded_token}
      delete micropost_path(user.microposts.first), headers: headers
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t("unauthorized.message")
    end

    it "has status ok when delete success with user is admin" do
      other_user = create(:user_admin)
      headers = {"AUTH-TOKEN": other_user.generate_new_encoded_token}
      delete micropost_path(user.microposts.first), headers: headers
      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)["success"]).to eql true
    end

    it "has status ok when delete success with correct user" do
      delete micropost_path(user.microposts.first), headers: headers
      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)["success"]).to eql true
    end

    it "has status internal_server_error when delete fail" do
      allow_any_instance_of(Micropost).to receive(:destroy!).and_raise ActiveRecord::RecordNotDestroyed
      delete micropost_path(user.microposts.first), headers: headers
      expect(response).to have_http_status :internal_server_error
      expect(JSON.parse(response.body)["success"]).to eql false
    end
  end
end
