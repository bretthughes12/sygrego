# frozen_string_literal: true
require 'pp'

class Ability
  include CanCan::Ability

  def initialize(user, session)

    if user.nil?
      can :read, Page

    elsif session["current_role"] == "admin"
      can :manage, :all

    elsif session["current_role"] == "church_rep"
      can :update, Group do |group|
        user.groups.include?(group) || user.role?(:admin)
      end
      can :read, Page
      can [:available_roles, :switch], Role if user.roles.count > 1
      can [:available_groups, :switch], Group if user.groups.count > 1
    
    elsif session["current_role"] == "gc"
      can :update, Group do |group|
        user.groups.include?(group) || user.role?(:admin)
      end
      can :read, Page
      can [:available_roles, :switch], Role if user.roles.count > 1
      can [:available_groups, :switch], Group if user.groups.count > 1
   
    elsif session["current_role"] == "participant"
      can :update, Group do |group|
        user.groups.include?(group) || user.role?(:admin)
      end
      can :read, Page
      can [:available_roles, :switch], Role if user.roles.count > 1
      can [:available_groups, :switch], Group if user.roles.count > 1

    end
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
