FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "123456" }
    password_confirmation { "123456" }
    auth_token { User.generate_unique_secure_token }

    factory :user_with_invalid_name do
      name { "" }
    end

    factory :user_with_invalid_email do
      email { "email" }
    end

    factory :user_with_invalid_password do
      password { "12345" }
      password_confirmation { "12345" }
    end

    factory :user_with_wrong_password_confirmation do
      password_confirmation { "12345" }
    end

    factory :user_admin do
      admin { true }
    end

    factory :user_with_microposts do
      transient do
        microposts_count { 5 }
      end
      after(:create) do |user, evaluate|
        create_list(:micropost, evaluate.microposts_count, user: user )
      end
    end
  end
end
