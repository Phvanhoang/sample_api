FactoryBot.define do
  factory :micropost do
    content { Faker::Lorem.sentence(word_count: 5) }

    factory :invalid_micropost do
      content { "" }
    end
  end
end
