module Reviews
  class RepliesController < ApplicationController
    before_action :authenticate_author!
    before_action :set_book
    before_action :set_review
    before_action :authorize_book_author!

    def create
      @reply = @review.review_replies.build(reply_params.merge(author: current_user.author_profile))

      if @reply.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              reply_form_dom_id,
              partial: "review_replies/form",
              locals: { book: @book, review: @review, reply: ReviewReply.new }
            )
          end
          format.html { redirect_to @book, notice: "Reply posted." }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              reply_form_dom_id,
              partial: "review_replies/form",
              locals: { book: @book, review: @review, reply: @reply }
            )
          end
          format.html { redirect_to @book, alert: @reply.errors.full_messages.to_sentence }
        end
      end
    end

    private

    def set_book
      @book = Book.find(params[:book_id])
    end

    def set_review
      @review = @book.reviews.find(params[:review_id])
    end

    def authorize_book_author!
      return if @book.authors.exists?(id: current_user.author_profile.id)

      redirect_to @book, alert: "Only this book's authors can reply to reviews."
    end

    def reply_params
      params.require(:review_reply).permit(:body)
    end

    def reply_form_dom_id
      ActionView::RecordIdentifier.dom_id(@review, :reply_form)
    end
  end
end
