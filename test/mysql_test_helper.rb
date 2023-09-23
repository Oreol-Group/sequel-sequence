# frozen_string_literal: true

require 'test_helper'

MysqlDB = Sequel.connect(
  adapter: 'mysql2',
  user: ENV['TEST_MYSQL_USERNAME'] || 'root',
  password: ENV['TEST_MYSQL_PASSWORD'] || 'root',
  host: ENV['TEST_MYSQL_HOST'] || '127.0.0.1',
  port: ENV['TEST_MYSQL_PORT'] || 3306,
  database: ENV['TEST_MYSQL_DATABASE'] || 'test'
)
# puts "Sequel::Database/test/ mariadb? = #{MysqlDB.mariadb?.inspect}"
# puts "Sequel::Database/test/ server_version = #{MysqlDB.server_version.inspect}"

module MysqlTestHelper
  def recreate_table
    MysqlDB.run 'DROP SEQUENCE IF EXISTS position'
    MysqlDB.run 'DROP TABLE IF EXISTS wares'
    MysqlDB.run 'DROP SEQUENCE IF EXISTS a'
    MysqlDB.run 'DROP SEQUENCE IF EXISTS b'
    MysqlDB.run 'DROP SEQUENCE IF EXISTS c'
    sql = 'CREATE TABLE wares (id INT AUTO_INCREMENT, slug VARCHAR(255), quantity INT DEFAULT(0), PRIMARY KEY(id));'
    MysqlDB.run sql
  end

  def with_migration(&block)
    migration_class = Sequel::Migration

    Sequel::Model.db = MysqlDB

    Class.new(migration_class, &block).new(MysqlDB)
  end
end
