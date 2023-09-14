# frozen_string_literal: true

require 'test_helper'

MysqlDB = Sequel.connect('mysql2://root:root@localhost/test')

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
