# frozen_string_literal: true
require 'pp'

class Ability
  include CanCan::Ability

  def initialize(user, session)

    if user.nil?
      can :read, Page
      can [:new_good_sports,
           :new_spirit,
           :new_volunteer,
           :create_good_sports,
           :create_spirit,
           :create_volunteer], Award
      can :create, SportsEvaluation
      can :create, IncidentReport
      can [:index, :update, :show, :search], LostItem

    elsif session["current_role"] == "admin"
      can :manage, :all

    elsif session["current_role"] == "church_rep"
      if user.status == "Verified"
        can [:update, 
             :edit_team_sports, 
             :edit_indiv_sports,
             :update_team_sports,
             :update_indiv_sports], MysygSetting do |ms|
          user.groups.include?(ms.group) || user.role?(:admin)
        end
        can [:index, :create], Payment
        can [:show, :update, :destroy], Payment do |payment|
          user.groups.include?(payment.group) || user.role?(:admin)
        end
        can :create, GroupExtra
        can [:show, :index, :update, :destroy], GroupExtra do |group_extra|
          user.groups.include?(group_extra.try(:group)) || user.role?(:admin)
        end
        can [:index], ParticipantExtra do |participant_extra|
          user.groups.include?(participant_extra.participant.group) || user.role?(:admin)
        end
        can [:index, 
            :search, 
            :create, 
            :new_import, 
            :import, 
            :drivers, 
            :approvals, 
            :wwccs, 
            :vaccinations, 
            :group_fees,
            :sports_plan,
            :camping_preferences,
            :sport_notes], Participant
        can [:show, 
            :update, 
            :destroy, 
            :new_voucher, 
            :add_voucher, 
            :delete_voucher, 
            :accept, 
            :reject, 
            :coming, 
            :edit_driver, 
            :update_driver, 
            :edit_wwcc, 
            :update_wwcc, 
            :edit_vaccination, 
            :update_vaccination,
            :edit_fees,
            :update_fees,
            :edit_camping_preferences,
            :update_camping_preferences,
            :edit_sport_notes,
            :update_sport_notes,
            :edit_sports], Participant do |participant|
          user.groups.include?(participant.group) || user.role?(:admin)
        end
        can [:index, :create, :sports_rules, :sports_draws], SportEntry
        can [:show, :update, :destroy, :confirm], SportEntry do |entry|
          user.groups.include?(entry.group) || user.role?(:admin)
        end
        can :index, SportPreference
        can [:add_to_sport_entry, :create_sport_entry, :remove_from_sport_entry], SportPreference do |pref|
          user.groups.include?(pref.group)
        end
        can [:create, :destroy, :make_captain], ParticipantsSportEntry
        can [:update, :index, :show, :destroy], User do |u|
          !(u.groups & user.groups).empty?
        end
        can :create, User
        can [:index, :available, :search], Volunteer
        can [:edit, :update, :release, :show], Volunteer do |volunteer|
          volunteer.participant.nil? || user.groups.include?(volunteer.try(:participant).group) || user.role?(:admin)
        end
      end
      
      can [:update, :edit_password, :update_password], User do |u|
        user == u
      end
      can :update, Group do |group|
        user.groups.include?(group) || user.role?(:admin)
      end
      can [:update, 
           :new_food_certificate, 
           :update_food_certificate, 
           :purge_food_certificate,
           :new_covid_plan,
           :update_covid_plan,
           :purge_covid_plan,
           :new_insurance,
           :update_insurance,
           :purge_insurance], EventDetail do |ev|
        user.groups.include?(ev.group) || user.role?(:admin)
      end
      can :read, Page
      can [:available_roles, :switch], Role if user.roles.count > 1
      can [:available_groups, :switch], Group if user.groups.count > 1 || user.role?(:admin)
      can [:available_participants, :switch], Participant if user.participants.count > 1 || user.role?(:admin)
      can [:new_good_sports,
        :new_spirit,
        :new_volunteer,
        :create_good_sports,
        :create_spirit,
        :create_volunteer], Award
      can :create, SportsEvaluation
      can :create, IncidentReport
      can [:index, :update, :show, :search], LostItem

    elsif session["current_role"] == "gc"
      if user.status == "Verified"
        can [:update, 
             :edit_team_sports, 
             :edit_indiv_sports,
             :update_team_sports,
             :update_indiv_sports], MysygSetting do |ms|
          user.groups.include?(ms.group) || user.role?(:admin)
        end
        can [:index, :create], Payment
        can [:show, :update, :destroy], Payment do |payment|
          user.groups.include?(payment.group) || user.role?(:admin)
        end
        can :create, GroupExtra
        can [:show, :index, :update, :destroy], GroupExtra do |group_extra|
          user.groups.include?(group_extra.try(:group)) || user.role?(:admin)
        end
        can [:index], ParticipantExtra do |participant_extra|
          user.groups.include?(participant_extra.participant.group) || user.role?(:admin)
        end
        can [:index, 
          :search, 
          :create, 
          :new_import, 
          :import, 
          :drivers, 
          :approvals, 
          :wwccs, 
          :vaccinations, 
          :group_fees,
          :sports_plan,
          :camping_preferences,
          :sport_notes], Participant
      can [:show, 
            :update, 
            :destroy, 
            :new_voucher, 
            :add_voucher, 
            :delete_voucher, 
            :accept, 
            :reject, 
            :coming, 
            :edit_driver, 
            :update_driver, 
            :edit_wwcc, 
            :update_wwcc, 
            :edit_vaccination, 
            :update_vaccination,
            :edit_fees,
            :update_fees,
            :edit_camping_preferences,
            :update_camping_preferences,
            :edit_sport_notes,
            :update_sport_notes,
            :edit_sports], Participant do |participant|
          user.groups.include?(participant.group) || user.role?(:admin)
        end
        can [:index, :create, :sports_rules, :sports_draws], SportEntry
        can [:show, :update, :destroy, :confirm], SportEntry do |entry|
          user.groups.include?(entry.group) || user.role?(:admin)
        end
        can :index, SportPreference
        can [:add_to_sport_entry, :create_sport_entry, :remove_from_sport_entry], SportPreference do |pref|
          user.groups.include?(pref.group)
        end
        can [:create, :destroy, :make_captain], ParticipantsSportEntry
        can [:index, :available, :search], Volunteer
        can [:edit, :update, :release, :show], Volunteer do |volunteer|
          volunteer.participant.nil? || user.groups.include?(volunteer.try(:participant).group) || user.role?(:admin)
        end
      end
      
      can [:update, :edit_password, :update_password], User do |u|
        user == u
      end
      can :update, Group do |group|
        user.groups.include?(group) || user.role?(:admin)
      end
      can [:update, 
           :new_food_certificate, 
           :update_food_certificate, 
           :purge_food_certificate,
           :new_covid_plan,
           :update_covid_plan,
           :purge_covid_plan,
           :new_insurance,
           :update_insurance,
           :purge_insurance], EventDetail do |ev|
        user.groups.include?(ev.group) || user.role?(:admin)
      end
      can :read, Page
      can [:available_roles, :switch], Role if user.roles.count > 1
      can [:available_groups, :switch], Group if user.groups.count > 1 || user.role?(:admin)
      can [:available_participants, :switch], Participant if user.participants.count > 1 || user.role?(:admin)
      can [:new_good_sports,
        :new_spirit,
        :new_volunteer,
        :create_good_sports,
        :create_spirit,
        :create_volunteer], Award
      can :create, SportsEvaluation
      can :create, IncidentReport
      can [:index, :update, :show, :search], LostItem

    elsif session["current_role"] == "participant"
      can [:update, :edit_password, :update_password], User do |u|
        user == u
      end
      can [:update, 
        :new_voucher, 
        :add_voucher, 
        :delete_voucher, 
        :drivers, 
        :update_drivers, 
        :edit_notes, 
        :update_notes], Participant do |participant|
          user.participants.include?(participant) || user.role?(:admin)
      end
      can [:index, :update_multiple], ParticipantExtra
      can [:index, :update_multiple], SportPreference
      can [:index], Volunteer
      can [:update, :release], Volunteer do |volunteer|
        volunteer.participant.nil? || user.participants.include?(volunteer.try(:participant)) || user.role?(:admin)
      end
      can :read, Page
      can [:available_roles, :switch], Role if user.roles.count > 1
      can [:available_groups, :switch], Group if user.groups.count > 1 || user.role?(:admin)
      can [:available_participants, :switch], Participant if user.participants.count > 1 || user.role?(:admin)
      can [:new_good_sports,
        :new_spirit,
        :new_volunteer,
        :create_good_sports,
        :create_spirit,
        :create_volunteer], Award
      can :create, SportsEvaluation
      can :create, IncidentReport
      can [:index, :update, :show, :search], LostItem
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
