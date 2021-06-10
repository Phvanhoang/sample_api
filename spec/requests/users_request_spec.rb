require "rails_helper"

RSpec.shared_examples "create" do |attribute, invalid_user|
  it "has status unprocessable_entity when invalid #{attribute}" do
    post users_path, params: {user: invalid_user}
    expect(response).to have_http_status :unprocessable_entity
    expect(response.body).to include assigns(:user).errors.to_json
  end
end

RSpec.shared_examples "update" do |attribute, invalid_user|
  it "has status unprocessable_entity when invalid #{attribute}" do
    invalid_user["current_password"] = "123456"
    patch user_path(user), params: {user: invalid_user.except(:auth_token)}, headers: headers

    expect(response).to have_http_status :unprocessable_entity
    expect(response.body).to include assigns(:user).errors.to_json
  end
end

RSpec.describe "Users", type: :request do
  describe "GET #index" do
    let!(:user){ create(:user_admin) }
    let!(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    it "get all users list" do
      get users_path, headers: headers
      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)["count"]).to eql 1
    end
  end

  describe "GET #show" do
    let(:user){ create(:user_with_microposts) }
    let(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    it "has status unauthorized when invalid token" do
      get user_path(user)
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t(".invalid_token")
    end

    it "has status not_found when user not found" do
      get user_path(-1), headers: headers
      expect(response).to have_http_status :not_found
      expect(response.body).to include "Couldn't find User with 'id'=-1"
    end

    it "has status ok when get user success" do
      get user_path(user), headers: headers
      expect(response).to have_http_status :ok
      expect(assigns(:user)).to eql user
    end
  end

  describe "POST #create" do
    context "with invalid user" do
      include_examples "create", :name, FactoryBot.attributes_for(:user_with_invalid_name)
      include_examples "create", :email, FactoryBot.attributes_for(:user_with_invalid_email)
      include_examples "create", :password, FactoryBot.attributes_for(:user_with_invalid_password)
      include_examples "create", :password_confirmation,
                       FactoryBot.attributes_for(:user_with_wrong_password_confirmation)
    end

    context "with valid user" do
      it "has status created" do
        post users_path, params: {user: attributes_for(:user)}

        expect(response).to have_http_status :created
        expect(response.body).to include I18n.t("users.created")
      end
    end
  end

  describe "PATCH #update" do
    let!(:user){ create(:user) }
    let!(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    context "with invalid user" do
      include_examples "update", :name, FactoryBot.attributes_for(:user_with_invalid_name)
      include_examples "update", :email, FactoryBot.attributes_for(:user_with_invalid_email)
      include_examples "update", :password, FactoryBot.attributes_for(:user_with_invalid_password)
      include_examples "update", :password_confirmation,
                       FactoryBot.attributes_for(:user_with_wrong_password_confirmation)
    end

    context "with valid user" do
      it "has status ok" do
        user_attributes = attributes_for :user
        user_attributes["current_password"] = "123456"
        patch user_path(user), params: {user: user_attributes.except(:auth_token)}, headers: headers

        expect(response).to have_http_status :ok
        expect(response.body).to include I18n.t("users.updated")
      end

      it "has status unprocessable_entity when wrong password" do
        user_attributes = attributes_for :user
        user_attributes["current_password"] = "12345"
        patch user_path(user), params: {user: user_attributes.except(:auth_token)}, headers: headers

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to include I18n.t("users.wrong_password")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user){ create(:user_admin) }
    let(:headers) { {"AUTH-TOKEN": user.generate_new_encoded_token} }

    it "has status unauthorized when invalid token" do
      get user_path(user)
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t(".invalid_token")
    end

    it "has status not_found when user not found" do
      get user_path(-1), headers: headers
      expect(response).to have_http_status :not_found
      expect(response.body).to include "Couldn't find User with 'id'=-1"
    end

    it "has status unauthorized when user is not admin" do
      user = create(:user)
      headers = {"AUTH-TOKEN": user.generate_new_encoded_token}
      delete user_path(user), headers: headers
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include I18n.t("unauthorized.message")
    end

    it "has status no_content when delete success" do
      other_user = create :user
      delete user_path(other_user), headers: headers
      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)["success"]).to eql true
    end

    it "has status internal_server_error when delete fail" do
      allow_any_instance_of(User).to receive(:destroy!).and_raise ActiveRecord::RecordNotDestroyed
      other_user = create :user
      delete user_path(other_user), headers: headers
      expect(response).to have_http_status :internal_server_error
      expect(JSON.parse(response.body)["success"]).to eql false
    end
  end
end
