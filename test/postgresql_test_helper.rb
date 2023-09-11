# frozen_string_literal: true

require 'test_helper'

PostgresqlDB = Sequel.connect('postgres:///test')

Sequel::Model.db = PostgresqlDB

class Thing < Sequel::Model
end

class InheritedThing < Thing
end

class Master < Sequel::Model
end

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
end
