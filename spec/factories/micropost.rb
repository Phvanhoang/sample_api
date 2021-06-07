FactoryBot.define do
  factory :micropost do
    content { Faker::Lorem.sentence(word_count: 5) }
  end
end
