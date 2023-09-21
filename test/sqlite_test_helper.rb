# frozen_string_literal: true

require 'test_helper'
require 'logger'

SQLiteDB = Sequel.sqlite(
  ENV['TEST_SQLITE_DATABASE'] || 'db/test.sqlite3',
  loggers: [Logger.new($stdout)]
)

module SqliteTestHelper
  def recreate_table
    SQLiteDB.drop_sequence 'position'
    SQLiteDB.run 'DROP TABLE IF EXISTS objects'
    SQLiteDB.drop_sequence 'a'
    SQLiteDB.drop_sequence 'b'
    SQLiteDB.drop_sequence 'c'
    sql = 'CREATE TABLE objects (id INTEGER PRIMARY KEY AUTOINCREMENT, quantity INTEGER DEFAULT(0), slug VARCHAR(255));'
    SQLiteDB.run sql
  end

  def with_migration(&block)
    migration_class = Sequel::Migration

    Sequel::Model.db = SQLiteDB

    Class.new(migration_class, &block).new(SQLiteDB)
  end
end
