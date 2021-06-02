class User < ApplicationRecord
  before_save ->{email.downcase!}
  after_save :generate_new_token
  has_secure_password
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
                                  foreign_key: :follower_id,
                                  dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
                                   foreign_key: :followed_id,
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  validates :name, presence: true,
            length: {maximum: Settings.user.name.max_length}
  validates :email, presence: true, uniqueness: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: Settings.user.email.regex}
  validates :password, presence: true,
            length: {minimum: Settings.user.password.min_length}

  def generate_new_encoded_token
    payload = {auth_token: auth_token,
               exp: Time.now.to_i + Settings.expire.weeks}
    JWT.encode payload, ENV["API_SECURE_KEY"], Settings.algorithm
  end

  private

  def generate_new_token
    update_column :auth_token, User.generate_unique_secure_token
  end
end
