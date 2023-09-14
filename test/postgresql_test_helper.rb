# frozen_string_literal: true

require 'test_helper'

PostgresqlDB = Sequel.connect('postgres://postgres:postgres@127.0.0.1:5432/test')

module PostgresqlTestHelper
  def recreate_table
    PostgresqlDB.run 'DROP TABLE IF EXISTS things'
    PostgresqlDB.run 'DROP SEQUENCE IF EXISTS position'
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
