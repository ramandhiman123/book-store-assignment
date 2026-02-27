class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book

  def create
    @review = @book.reviews.build(review_params.merge(user: current_user))
    @reviews = @book.reviews.includes(:user).order(created_at: :desc)

    if @review.save
      ReviewNotificationJob.perform_later(@review.id)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @book, notice: "Review created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("review_form", partial: "reviews/form", locals: { book: @book, review: @review }) }
        format.html { render "books/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_book
    @book = Book.with_show_includes.find(params[:book_id])
  end

  def review_params
    params.require(:review).permit(:rating, :review)
  end
end
