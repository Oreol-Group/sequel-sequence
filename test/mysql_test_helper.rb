# frozen_string_literal: true

require 'test_helper'
# require 'logger'

MysqlDB = Sequel.connect(
  # loggers: [Logger.new($stdout)],
  adapter: 'mysql2',
  user: ENV['TEST_MYSQL_USERNAME'] || 'root',
  password: ENV['TEST_MYSQL_PASSWORD'] || 'rootroot',
  host: ENV['TEST_MYSQL_HOST'] || '0.0.0.0',
  port: ENV['TEST_MYSQL_PORT'] || 3360,
  database: ENV['TEST_MYSQL_DATABASE'] || 'test'
)

module MysqlTestHelper
  def recreate_table
    MysqlDB.drop_table :creators, if_exists: true
    MysqlDB.drop_sequence :position_id, if_exists: true
    MysqlDB.drop_sequence :position
    MysqlDB.drop_table :stuffs, if_exists: true
    MysqlDB.drop_sequence 'a'
    MysqlDB.drop_sequence 'b'
    MysqlDB.drop_sequence 'c'
    sql = 'CREATE TABLE stuffs (id INT AUTO_INCREMENT PRIMARY KEY, slug VARCHAR(255), quantity INT DEFAULT(0));'
    MysqlDB.run sql
  end

  def with_migration(&block)
    migration_class = Sequel::Migration

    Sequel::Model.db = MysqlDB

    Class.new(migration_class, &block).new(MysqlDB)
  end

  def sequence_table_exists?(name)
    table_list = MysqlDB.fetch('SHOW TABLES;').all.map { |_key, value| value }
    table_list.include?(name)
  end
end
