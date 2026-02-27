class AuthenticatedReviewMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if review_create_request?(request) && unauthenticated?(env)
      return unauthorized_response
    end

    @app.call(env)
  end

  private

  def review_create_request?(request)
    request.post? && request.path.match?(%r{\A/books/\d+/reviews\z})
  end

  def unauthenticated?(env)
    warden = env["warden"]
    return false if warden&.authenticated?(:user)

    session_key = env.dig("rack.session", "warden.user.user.key")
    session_key.blank?
  end

  def unauthorized_response
    [
      401,
      { "Content-Type" => "application/json" },
      [{ error: "Unauthorized" }.to_json]
    ]
  end
end
