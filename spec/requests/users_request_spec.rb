require "rails_helper"

RSpec.shared_examples "create" do |attribute, invalid_user|
  it "has status unprocessable_entity when invalid #{attribute}" do
    post users_path, params: {user: invalid_user}
    expect(response).to have_http_status :unprocessable_entity
    expect(response.body).to include assigns(:user).errors.to_json
  end
end

RSpec.describe "Users", type: :request do
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
end
