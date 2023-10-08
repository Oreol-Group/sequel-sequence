# frozen_string_literal: true

require 'test_helper'
# require 'logger'

PostgresqlDB = Sequel.connect(
  # loggers: [Logger.new($stdout)],
  adapter: 'postgres',
  user: ENV['TEST_POSTGRES_USERNAME'] || 'postgres',
  password: ENV['TEST_POSTGRES_PASSWORD'] || 'postgres',
  host: ENV['TEST_POSTGRES_HOST'] || 'localhost',
  port: ENV['TEST_POSTGRES_PORT'] || 5432,
  database: ENV['TEST_POSTGRES_DATABASE'] || 'test'
)

module PostgresqlTestHelper
  def recreate_table
    PostgresqlDB.run 'DROP TABLE IF EXISTS masters'
    PostgresqlDB.run 'DROP SEQUENCE IF EXISTS position'
    PostgresqlDB.run 'DROP SEQUENCE IF EXISTS position_id'
    PostgresqlDB.run 'DROP TABLE IF EXISTS things'
    PostgresqlDB.run 'DROP SEQUENCE IF EXISTS a'
    PostgresqlDB.run 'DROP SEQUENCE IF EXISTS b'
    PostgresqlDB.run 'DROP SEQUENCE IF EXISTS c'
    sql = 'CREATE TABLE things (id SERIAL PRIMARY KEY, slug VARCHAR(255), quantity INTEGER DEFAULT 0);'
    PostgresqlDB.run sql
  end

  def with_migration(&block)
    migration_class = Sequel::Migration

    Sequel::Model.db = PostgresqlDB

    Class.new(migration_class, &block).new(PostgresqlDB)
  end
end
