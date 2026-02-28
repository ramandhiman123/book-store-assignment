class BooksController < ApplicationController
  before_action :set_filters, only: :index

  def index
    @page = [params.fetch(:page, 1).to_i, 1].max
    @per_page = [[params.fetch(:per_page, 12).to_i, 1].max, 50].min

    scope = Book.with_index_includes
    scope = scope.where(category_id: @category_id) if @category_id.present?
    scope = scope.joins(:tags).where(tags: { name: @tag }).distinct if @tag.present?

    @total_count = scope.count
    @total_pages = [(@total_count / @per_page.to_f).ceil, 1].max
    @page = [@page, @total_pages].min

    @books = scope
             .order(created_at: :desc)
             .limit(@per_page)
             .offset((@page - 1) * @per_page)
    @books.each(&:ensure_cover_photo!)

    @categories = Category.order(:name)
  end

  def show
    @book = Book.with_show_includes.find(params[:id])
    @book.ensure_cover_photo!
    @reviews = @book.reviews.includes(:user).order(created_at: :desc)
    @review = Review.new
    @can_reply = current_user&.author_profile.present? && @book.authors.exists?(id: current_user.author_profile.id)
  end

  private

  def set_filters
    @category_id = params[:category_id].presence
    @tag = params[:tag].presence&.downcase
  end
end
