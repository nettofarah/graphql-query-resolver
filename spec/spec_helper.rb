$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'graphql/query_resolver'
require 'active_record'
require 'byebug'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

require 'support/schema'
require 'support/activerecord_models'
require 'support/factories'
require 'support/graphql_schema'

RSpec.configure do |c|
  c.around(:example) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

def track_queries
  selects = []
  queries_collector = lambda do |name, start, finish, id, payload|
    selects << payload
  end

  ActiveRecord::Base.connection.clear_query_cache
  ActiveSupport::Notifications.subscribed(queries_collector, 'sql.active_record') do
    yield
  end

  selects.map { |sel| sel[:sql].strip.gsub("  ", " ") }
end
