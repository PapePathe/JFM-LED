class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  private

  if Rails.env.staging?
    http_basic_authenticate_with name: "juste", password: "lejusticier"
  end

  def after_sign_in_path_for(resource)
     "/#{resource.role}/dashboard"
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:first_name, :last_name, :phone, :role, :password, :photo, :password_confirmation, :email, :remember_me, :branch_id, :company_id]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

end
