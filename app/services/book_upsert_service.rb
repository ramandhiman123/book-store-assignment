class BookUpsertService
  def initialize(payloads)
    @payloads = Array(payloads)
  end

  def call
    ActiveRecord::Base.transaction do
      @payloads.each do |payload|
        upsert_single(payload)
      end
    end
  end

  private

  def upsert_single(payload)
    data = payload.to_h.symbolize_keys
    category = Category.find_or_create_by!(name: normalized_text(data.fetch(:category_name)))

    author_records = Array(data[:authors]).map do |author_name|
      Author.find_or_create_by!(name: normalized_text(author_name))
    end

    tag_records = Array(data[:tags]).map do |tag_name|
      Tag.find_or_create_by!(name: normalized_tag_name(tag_name))
    end

    book_attrs = data.fetch(:book).symbolize_keys.slice(:title, :description, :price)
    book = Book.find_or_initialize_by(title: book_attrs[:title], category: category)
    book.assign_attributes(book_attrs)
    book.category = category
    book.save!

    book.authors = author_records
    book.tags = tag_records

    attach_cover_photo(book, data[:cover_photo_path]) if data[:cover_photo_path].present?
    book.attach_default_cover!

    book
  end

  def attach_cover_photo(book, path)
    return unless File.exist?(path)
    return if already_attached_cover?(book, path)

    File.open(path, "rb") do |file|
      book.cover_photo.attach(
        io: file,
        filename: File.basename(path),
        content_type: Marcel::MimeType.for(file, name: File.basename(path))
      )
    end
  end

  def already_attached_cover?(book, path)
    return false unless book.cover_photo.attached?

    current_name = book.cover_photo.filename.to_s
    current_name == File.basename(path)
  end

  def normalized_text(value)
    value.to_s.strip
  end

  def normalized_tag_name(value)
    value.to_s.strip.downcase
  end
end
