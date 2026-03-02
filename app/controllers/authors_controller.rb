class AuthorsController < ApplicationController
  def new
    return redirect_to author_dashboard_path if current_user&.author_profile.present?

    @user = current_user || User.new
    @author = Author.new
  end

  def create
    author_name = author_params[:name].to_s.strip
    @user = current_user || User.new(user_params)

    if current_user.present?
      @author = Author.new(name: author_name, user: @user)
      return render :new, status: :unprocessable_entity unless @author.valid?

      @author.save!
      redirect_to author_dashboard_path, notice: "Author profile created successfully."
    else
      @author = Author.new(name: author_name)
      return render :new, status: :unprocessable_entity unless @user.valid? && @author.valid?

      ActiveRecord::Base.transaction do
        @user.save!
        @author.update!(user: @user)
      end

      sign_in(@user)
      redirect_to author_dashboard_path, notice: "Author account created successfully."
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:author_registration).permit(:email, :password, :password_confirmation)
  end

  def author_params
    params.require(:author_registration).permit(:name)
  end
end
