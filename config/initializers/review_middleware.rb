if defined?(Warden::Manager)
  Rails.application.config.middleware.insert_after Warden::Manager, AuthenticatedReviewMiddleware
else
  Rails.application.config.middleware.use AuthenticatedReviewMiddleware
end
