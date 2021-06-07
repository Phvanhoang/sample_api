# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    can :create, User
    return unless user

    if user.admin
      can :manage, :all
      cannot [:create, :delete], Relationship
    else
      can :read, User
      can :update, User, id: user.id
      can :manage, Micropost, user_id: user.id
      can :read, Micropost
      can :create, Relationship
      can :delete, Relationship, follower_id: user.id
    end
  end
end
