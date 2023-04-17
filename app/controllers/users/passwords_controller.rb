# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController

  layout 'users'

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PATCH /resource/password
  def update
    super
    session["current_role"] = current_user.default_role if current_user
    session["current_group"] = current_user.default_group if current_user
    session["current_participant"] = current_user.default_participant if current_user
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
