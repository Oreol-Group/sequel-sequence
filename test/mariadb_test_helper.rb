# frozen_string_literal: true

require 'test_helper'

MariaDB = Sequel.connect(
  adapter: 'mysql2',
  user: ENV['TEST_MARIA_USERNAME'] || 'root',
  password: ENV['TEST_MARIA_PASSWORD'] || 'root',
  host: ENV['TEST_MARIA_HOST'] || '127.0.0.1',
  port: ENV['TEST_MARIA_PORT'] || 3306,
  database: ENV['TEST_MARIA_DATABASE'] || 'test'
)

module MariadbTestHelper
  def recreate_table
    MariaDB.run 'DROP TABLE IF EXISTS builders'
    MariaDB.run 'DROP SEQUENCE IF EXISTS position'
    MariaDB.run 'DROP SEQUENCE IF EXISTS position_id'
    MariaDB.run 'DROP TABLE IF EXISTS wares'
    MariaDB.run 'DROP SEQUENCE IF EXISTS a'
    MariaDB.run 'DROP SEQUENCE IF EXISTS b'
    MariaDB.run 'DROP SEQUENCE IF EXISTS c'
    sql = 'CREATE TABLE wares (id INT AUTO_INCREMENT, slug VARCHAR(255), quantity INT DEFAULT(0), PRIMARY KEY(id));'
    MariaDB.run sql
  end

  def with_migration(&block)
    migration_class = Sequel::Migration

    Sequel::Model.db = MariaDB

    Class.new(migration_class, &block).new(MariaDB)
  end
end
