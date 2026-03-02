module QueryCounter
  IGNORED_PAYLOAD_NAMES = %w[SCHEMA TRANSACTION].freeze

  def count_queries
    count = 0
    callback = lambda do |_name, _start, _finish, _message_id, payload|
      sql = payload[:sql].to_s
      next if IGNORED_PAYLOAD_NAMES.include?(payload[:name])
      next if sql.match?(/\A(?:BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/i)

      count += 1
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      ActiveRecord::Base.uncached { yield }
    end

    count
  end
end

RSpec.configure do |config|
  config.include QueryCounter
end
