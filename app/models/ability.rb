# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    can :create, User
    return unless user

    if user.admin
      can :manage, :all
      cannot :destroy, User, id: user.id
      cannot :destroy, Relationship
    else
      can :read, User
      can :update, User, id: user.id
      can :manage, Micropost, user_id: user.id
      can :read, Micropost
      can :create, Relationship
      can :destroy, Relationship, follower_id: user.id
    end
  end
end
