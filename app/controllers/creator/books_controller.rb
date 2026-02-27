module Creator
  class BooksController < ApplicationController
    before_action :authenticate_author!

    def new
      @book = Book.new
      @categories = Category.order(:name)
    end

    def create
      @book = Book.new(book_params)
      @categories = Category.order(:name)

      ActiveRecord::Base.transaction do
        @book.save!
        @book.attach_default_cover!
        @book.authors << current_author_record unless @book.authors.exists?(id: current_author_record.id)
        attach_tags(@book)
      end

      redirect_to @book, notice: "Book created successfully."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end

    private

    def book_params
      params.require(:book).permit(:title, :description, :price, :category_id, :cover_photo)
    end

    def current_author_record
      current_user.author_profile
    end

    def attach_tags(book)
      tag_names.each do |tag_name|
        tag = Tag.find_or_create_by!(name: tag_name)
        book.tags << tag unless book.tags.exists?(id: tag.id)
      end
    end

    def tag_names
      params.fetch(:book, {}).fetch(:tag_list, "").split(",").map { |name| name.strip.downcase }.reject(&:blank?).uniq
    end
  end
end
