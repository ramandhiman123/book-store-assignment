require "base64"
require "fileutils"
require "open-uri"

BOOK_COVER_URLS = {
  "great-adventure" => "https://picsum.photos/id/24/800/1200.jpg",
  "history-of-rails" => "https://picsum.photos/id/28/800/1200.jpg",
  "pragmatic-ruby-patterns" => "https://picsum.photos/id/48/800/1200.jpg",
  "catalog-1" => "https://picsum.photos/id/50/800/1200.jpg",
  "catalog-2" => "https://picsum.photos/id/55/800/1200.jpg",
  "catalog-3" => "https://picsum.photos/id/63/800/1200.jpg",
  "catalog-4" => "https://picsum.photos/id/71/800/1200.jpg",
  "catalog-5" => "https://picsum.photos/id/81/800/1200.jpg"
}.freeze
FALLBACK_PNG_BASE64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADUlEQVR42mNk+M8AAwUBAS8B2i8AAAAASUVORK5CYII=".freeze
FALLBACK_JPG_BASE64 = "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAVEAEBAAAAAAAAAAAAAAAAAAAAAf/aAAwDAQACEAMQAAAB6gD/xAAUEAEAAAAAAAAAAAAAAAAAAAAQ/9oACAEBAAEFAmP/xAAUEQEAAAAAAAAAAAAAAAAAAAAQ/9oACAEDAQE/ASP/xAAUEQEAAAAAAAAAAAAAAAAAAAAQ/9oACAECAQE/ASP/xAAUEAEAAAAAAAAAAAAAAAAAAAAQ/9oACAEBAAY/AmP/xAAUEAEAAAAAAAAAAAAAAAAAAAAQ/9oACAEBAAE/IX//2Q==".freeze

def seed_cover_path(name, format: :jpg, url: nil)
  extension = format == :png ? "png" : "jpg"
  file_path = Rails.root.join("tmp", "seed_covers", "#{name.parameterize}.#{extension}")
  return file_path if File.exist?(file_path)

  FileUtils.mkdir_p(file_path.dirname)
  fallback_encoded = extension == "png" ? FALLBACK_PNG_BASE64 : FALLBACK_JPG_BASE64

  if url.present?
    URI.open(url) do |remote_file|
      File.binwrite(file_path, remote_file.read)
    end
    return file_path
  end

  File.binwrite(file_path, Base64.decode64(fallback_encoded))
  file_path
rescue StandardError => e
  Rails.logger.warn("Seed cover download failed for #{name}: #{e.class} #{e.message}")
  File.binwrite(file_path, Base64.decode64(fallback_encoded))
  file_path
end

fiction = Category.find_or_create_by!(name: "Fiction")
non_fiction = Category.find_or_create_by!(name: "Non-fiction")
technology = Category.find_or_create_by!(name: "Technology")

jane = Author.find_or_create_by!(name: "Jane Doe")
john = Author.find_or_create_by!(name: "John Smith")
ava = Author.find_or_create_by!(name: "Ava Ray")

tag_fantasy = Tag.find_or_create_by!(name: "fantasy")
tag_history = Tag.find_or_create_by!(name: "history")
tag_scifi = Tag.find_or_create_by!(name: "sci-fi")
tag_ruby = Tag.find_or_create_by!(name: "ruby")
tag_mystery = Tag.find_or_create_by!(name: "mystery")
tag_bestseller = Tag.find_or_create_by!(name: "bestseller")
tag_classic = Tag.find_or_create_by!(name: "classic")
tag_biography = Tag.find_or_create_by!(name: "biography")

book1 = Book.find_or_create_by!(title: "The Great Adventure", category: fiction) do |book|
  book.description = "An epic fantasy adventure."
  book.price = 19.99
end
book1.authors = [jane]
book1.tags = [tag_fantasy, tag_scifi]

book2 = Book.find_or_create_by!(title: "History of Rails", category: non_fiction) do |book|
  book.description = "A deep dive into the history of Ruby on Rails."
  book.price = 29.99
end
book2.authors = [john, ava]
book2.tags = [tag_history, tag_ruby]

book3 = Book.find_or_create_by!(title: "Pragmatic Ruby Patterns", category: technology) do |book|
  book.description = "Practical Ruby design patterns with real world examples."
  book.price = 24.50
end
book3.authors = [ava]
book3.tags = [tag_ruby, tag_classic]

{
  book1 => seed_cover_path("great-adventure", format: :jpg, url: BOOK_COVER_URLS["great-adventure"]),
  book2 => seed_cover_path("history-of-rails", format: :jpg, url: BOOK_COVER_URLS["history-of-rails"]),
  book3 => seed_cover_path("pragmatic-ruby-patterns", format: :jpg, url: BOOK_COVER_URLS["pragmatic-ruby-patterns"])
}.each do |book, image_path|
  allowed_types = %w[image/png image/jpeg]
  if book.cover_photo.attached? && allowed_types.exclude?(book.cover_photo.blob.content_type)
    book.cover_photo.purge
  end
  next if book.cover_photo.attached? && book.cover_photo.blob.byte_size.to_i > 100

  File.open(image_path, "rb") do |file|
    content_type = File.extname(image_path) == ".jpg" ? "image/jpeg" : "image/png"
    book.cover_photo.attach(
      io: file,
      filename: File.basename(image_path),
      content_type: content_type
    )
  end
end

demo_user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

guest_user = User.find_or_create_by!(email: "guest@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

author_user = User.find_or_create_by!(email: "author@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

Author.find_or_create_by!(user: author_user) { |a| a.name = "Seed Author" }

Review.find_or_create_by!(user: demo_user, book: book1, rating: 5, review: "Amazing book with great pacing!")
Review.find_or_create_by!(user: guest_user, book: book1, rating: 4, review: "Fun read and strong characters.")
Review.find_or_create_by!(user: demo_user, book: book2, rating: 5, review: "Excellent historical overview.")

15.times do |i|
  extra_book = Book.find_or_create_by!(title: "Catalog Sample #{i + 1}", category: fiction) do |book|
    book.description = "Seeded sample book ##{i + 1} for pagination and filtering demos."
    book.price = (8.99 + i).round(2)
  end
  extra_book.authors = [jane]
  tag_sets = [
    [tag_fantasy, tag_bestseller],
    [tag_scifi, tag_classic],
    [tag_mystery, tag_bestseller],
    [tag_history, tag_biography],
    [tag_ruby, tag_bestseller]
  ]
  extra_book.tags = tag_sets[i % tag_sets.length]
  cover_key = "catalog-#{(i % 5) + 1}"
  cover_path = seed_cover_path(cover_key, format: :jpg, url: BOOK_COVER_URLS[cover_key])

  if extra_book.cover_photo.attached? && !%w[image/png image/jpeg].include?(extra_book.cover_photo.blob.content_type)
    extra_book.cover_photo.purge
  end

  if !extra_book.cover_photo.attached? || extra_book.cover_photo.blob.byte_size.to_i <= 100
    File.open(cover_path, "rb") do |file|
      extra_book.cover_photo.attach(
        io: file,
        filename: File.basename(cover_path),
        content_type: "image/jpeg"
      )
    end
  end
end
