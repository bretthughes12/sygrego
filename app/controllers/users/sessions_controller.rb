# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  layout 'users'

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    session["current_role"] = current_user.default_role
    session["current_group"] = current_user.default_group
    session["current_participant"] = current_user.default_participant
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
