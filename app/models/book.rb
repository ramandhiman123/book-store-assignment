require "stringio"
require "base64"

class Book < ApplicationRecord
  DEFAULT_COVER_PNG_BASE64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADUlEQVR42mNk+M8AAwUBAS8B2i8AAAAASUVORK5CYII=".freeze

  belongs_to :category

  has_many :reviews, dependent: :destroy
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags

  has_one_attached :cover_photo

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :with_index_includes, lambda {
    includes(:category, :authors, :tags, cover_photo_attachment: :blob)
  }

  scope :with_show_includes, lambda {
    includes(:category, :authors, :tags, cover_photo_attachment: :blob, reviews: [:user, { review_replies: { author: :user } }])
  }

  def average_rating
    if reviews.loaded?
      return 0.0 if reviews.empty?

      return reviews.map(&:rating).sum.fdiv(reviews.size).round(2)
    end

    reviews.average(:rating).to_f.round(2)
  end

  def attach_default_cover!(force: false)
    return if cover_photo_available? && !force

    io = StringIO.new(Base64.decode64(DEFAULT_COVER_PNG_BASE64))
    cover_photo.attach(
      io: io,
      filename: "default-cover-#{id || 'new'}.png",
      content_type: "image/png"
    )
  end

  def cover_photo_available?
    return false unless cover_photo.attached?

    cover_photo.blob.service.exist?(cover_photo.blob.key)
  rescue StandardError
    false
  end

  def ensure_cover_photo!
    attach_default_cover!(force: true) if cover_needs_repair?
  end

  def cover_needs_repair?
    return true unless cover_photo_available?
    return true unless %w[image/png image/jpeg].include?(cover_photo.blob.content_type)
    return true if cover_photo.blob.byte_size.to_i <= 100

    false
  end
end
