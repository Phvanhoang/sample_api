require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user) }
  describe "POST #create" do
    context "with invalid session" do
      it "has status 401 when invalid email" do
        post sessions_path, params: {session:{email: "invalid@mail.com", password: ""}}
        expect(response).to have_http_status(401)
        expect(response.body).to include(I18n.t("sessions.invalid"))
      end

      it "has status 401 when invalid password" do
        post sessions_path, params: {session:{email: User.first.email, password: "invalid"}}
        expect(response).to have_http_status(401)
        expect(response.body).to include(I18n.t("sessions.invalid"))
      end
    end

    context "with valid session" do
      it "has successful status when valid email" do
        post sessions_path, params: {session:{email: User.first.email, password: "123456"}}
        expect(response).to be_successful
        expect(response.body).to include(I18n.t("sessions.logged_in"))
      end
    end
  end
end
