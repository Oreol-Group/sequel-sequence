# frozen_string_literal: true

require 'sequel/database'
require 'sequel/adapters/postgres'
require 'sequel/adapters/mysql2'
require 'sequel/adapters/sqlite'
require 'sequel/error'
require 'sequel/sequence/database_ext_connection'

module Sequel
  module Sequence
    require 'sequel/sequence/database'

    module Database
      require 'sequel/sequence/database/postgresql'
      require 'sequel/sequence/database/sqlite'
    end
  end
end

Sequel::Database.include(
  Sequel::Sequence::Database
)
Sequel::Postgres::Database.include(
  Sequel::Sequence::Database::PostgreSQL
)
Sequel::SQLite::Database.include(
  Sequel::Sequence::Database::SQLite
)
