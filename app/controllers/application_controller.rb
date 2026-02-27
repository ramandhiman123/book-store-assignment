class ApplicationController < ActionController::Base
  private

  def authenticate_author!
    authenticate_user!
    return if current_user&.author_profile.present?

    redirect_to root_path, alert: "Only authors can perform this action."
  end
end
