class Micropost < ApplicationRecord
  belongs_to :user
  scope :by_created_at, ->{order created_at: :desc}
  scope :following_microposts, ->(ids){where("user_id IN (?)", ids)}
  validates :user_id, presence: true
  validates :content, presence: true,
            length: {maximum: Settings.micropost.content.max_length}
end
