# frozen_string_literal: true

require 'sequel/database'
require 'sequel/error'
require 'sequel/sequence/database_ext_connection'

module Sequel
  module Sequence
    require 'sequel/sequence/database'
  end
end

Sequel::Database.include(
  Sequel::Sequence::Database
)

begin
  if Gem::Specification.find_by_name('pg')
    require 'sequel/adapters/postgres'

    module Sequel
      module Sequence
        module Database
          require 'sequel/sequence/database/postgresql'
        end
      end
    end

    Sequel::Postgres::Database.include(
      Sequel::Sequence::Database::PostgreSQL
    )
  end
rescue Gem::LoadError
  # do nothing
end

begin
  require 'sequel/adapters/mysql2' if Gem::Specification.find_by_name('mysql2')
rescue Gem::LoadError
  # do nothing
end

begin
  if Gem::Specification.find_by_name('sqlite3')
    require 'sequel/adapters/sqlite'

    module Sequel
      module Sequence
        module Database
          require 'sequel/sequence/database/sqlite'
        end
      end
    end

    Sequel::SQLite::Database.include(
      Sequel::Sequence::Database::SQLite
    )
  end
rescue Gem::LoadError
  # do nothing
end
