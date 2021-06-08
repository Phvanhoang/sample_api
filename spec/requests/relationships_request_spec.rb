require "rails_helper"

RSpec.describe "Relationships", type: :request do
  describe "POST #create" do
    let!(:user){ create(:user) }
    let!(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    it "has status unauthorized when invalid token" do
      post relationships_path
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t(".invalid_token")
    end

    it "has status unprocessable_entity when followed user not found" do
      post relationships_path, params: {followed_id: -1} ,headers: headers
      expect(response).to have_http_status :unprocessable_entity
      expect(response.body).to include I18n.t("relationships.user_not_found")
    end

    it "has status created when not following before " do
      other_user = create(:user)
      post relationships_path, params: {followed_id: other_user.id} ,headers: headers
      expect(response).to have_http_status :created
      expect(response.body).to include I18n.t("relationships.created")
    end

    it "has status unprocessable_entity when following before" do
      other_user = create(:user)
      user.follow other_user
      post relationships_path, params: {followed_id: other_user.id} ,headers: headers
      expect(response).to have_http_status :unprocessable_entity
      expect(response.body).to include I18n.t("relationships.followed_user_error")
    end
  end
end
