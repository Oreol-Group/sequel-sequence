# frozen_string_literal: true

require 'test_helper'
require 'logger'

SQLiteDB = Sequel.connect(
  "sqlite://#{ENV.fetch('TEST_SQLITE_DATABASE', nil) || 'db/test.sqlite3'}",
  loggers: [Logger.new($stdout)]
)

module SqliteTestHelper
  def recreate_table
    SQLiteDB.drop_table :apprentices, if_exists: true
    SQLiteDB.drop_sequence :position
    SQLiteDB.drop_sequence :position_id, if_exists: true
    SQLiteDB.drop_table :objects, if_exists: true
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

  def sequence_table_exists?(name)
    sql = "SELECT name FROM sqlite_schema WHERE type ='table' AND name NOT LIKE 'sqlite_%';"
    table_list = SQLiteDB.fetch(sql).all.map { |_key, value| value }
    table_list.include?(name)
  end
end
