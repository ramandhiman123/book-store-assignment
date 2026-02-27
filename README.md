# Book Store Assignment

Production-style Rails bookstore with:
- Books, Categories, Authors, Reviews, Tags (custom tables, no tagging gem)
- Active Storage cover photos
- Devise authentication
- Middleware-protected review creation endpoint
- Background email notifications for new reviews
- Turbo Stream live updates for reviews + average rating
- Server-side pagination (no gem)
- N+1 query prevention and query-bound regression tests

## Core Features

- Public users can browse and filter books.
- Authenticated users can create reviews.
- Middleware rejects unauthenticated `POST /books/:book_id/reviews` with `401`.
- Author onboarding flow:
  - `Add Author` button in top nav
  - Author creation form (`name`, `email`, `password`, `password confirmation`)
  - Redirect to Author Dashboard with `Add Book` and `Add Category`

## Data Model

- `categories`, `authors`, `books`, `book_authors`, `reviews`, `users`, `tags`, `book_tags`, `active_storage_*`

## Setup

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
```

Run app:

```bash
bin/dev
```

## Test Suite (RSpec)

Run all:

```bash
bundle exec rspec
```

Includes:
- Model specs
- Request specs (pagination, filters, middleware/auth review creation)
- Job and mailer specs
- Service specs
- System specs for live updates and pagination demos
- N+1 bounded query specs

## Demo Evidence

### 1) Pagination screenshots

Run:

```bash
bundle exec rspec spec/system/pagination_demo_spec.rb
```

Generated files:
- `tmp/screenshots/books_index_page_1.png`
- `tmp/screenshots/books_index_page_2.png`

### 2) Live review update screenshots (Turbo/WebSocket)

Run:

```bash
bundle exec rspec spec/system/reviews_live_updates_spec.rb
```

Generated files:
- `tmp/screenshots/book_show_before_review.png`
- `tmp/screenshots/book_show_after_review.png`

### 3) Email notification evidence

Options:
1. Development mail preview: `http://localhost:3000/rails/mailers/author_mailer/review_notification`
2. Letter opener view after creating a review (development env)
3. Test evidence via:

```bash
bundle exec rspec spec/jobs/review_notification_job_spec.rb spec/mailers/author_mailer_spec.rb
```

## Important Routes

- `root` -> `books#index`
- `devise_for :users`
- `resources :books, only: [:index, :show]` with nested `reviews#create`
- `resources :authors, only: [:new, :create]`
- Author area:
  - `/author/dashboard`
  - `/author/books/new`
  - `/author/categories/new`
- Action Cable mounted at `/cable`
