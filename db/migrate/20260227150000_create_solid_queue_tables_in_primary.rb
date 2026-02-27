class CreateSolidQueueTablesInPrimary < ActiveRecord::Migration[7.1]
  TABLES = %w[
    solid_queue_blocked_executions
    solid_queue_claimed_executions
    solid_queue_failed_executions
    solid_queue_jobs
    solid_queue_pauses
    solid_queue_processes
    solid_queue_ready_executions
    solid_queue_recurring_executions
    solid_queue_recurring_tasks
    solid_queue_scheduled_executions
    solid_queue_semaphores
  ].freeze

  def up
    return if table_exists?(:solid_queue_processes)

    load Rails.root.join("db/queue_schema.rb")
  end

  def down
    TABLES.each do |table_name|
      drop_table table_name if table_exists?(table_name)
    end
  end
end
