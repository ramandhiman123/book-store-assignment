module Creator
  class DashboardsController < ApplicationController
    before_action :authenticate_author!

    def show
      @author = current_user.author_profile
      @books = @author.books.includes(:category).order(created_at: :desc).limit(10)
    end
  end
end
