# frozen_string_literal: true

# https://sequel.jeremyevans.net/rdoc/files/doc/sql_rdoc.html
# https://github.com/jeremyevans/sequel/blob/master/lib/sequel/database/connecting.rb
# See information about  disable_insert_returning in https://github.com/jeremyevans/sequel/blob/master/doc/release_notes/4.9.0.txt
module Sequel
  module Sequence
    module Database
      module PostgreSQL
        SEQUENCE_COMMENT = 'created by sequel-sequence'

        def quote_column_name(name)
          PG::Connection.quote_ident(name).freeze
        end

        def quote_sequence_name(name)
          PG::Connection.quote_connstr(name).freeze
        end

        def custom_sequence?(sequence_name)
          out = ''
          begin
            fetch("SELECT obj_description('#{sequence_name}'::regclass, 'pg_class');") do |row|
              out = row[:obj_description]
            end
          rescue Sequel::DatabaseError # PG::UndefinedTable
            return false
          end

          out == SEQUENCE_COMMENT
        end

        def check_sequences
          fetch('SELECT * FROM information_schema.sequences ORDER BY sequence_name').all.to_a
        end

        def create_sequence(name, options = {})
          increment = options[:increment] || options[:step]
          if_exists = build_exists_condition(options[:if_exists])
          name = quote_name(name.to_s)

          sql = ["CREATE SEQUENCE #{if_exists} #{name}"]
          sql << "INCREMENT BY #{increment}" if increment
          sql << "START WITH #{options[:start]}" if options[:start]
          sql << ';'
          sql << "COMMENT ON SEQUENCE #{name} IS '#{SEQUENCE_COMMENT}';"

          run(sql.join("\n"))
        end

        def drop_sequence(name)
          name = quote_name(name.to_s)
          sql = "DROP SEQUENCE IF EXISTS #{name}"
          run(sql)
        end

        def nextval(name)
          name = quote(name.to_s)
          out = nil
          fetch("SELECT nextval(#{name})") do |row|
            out = row[:nextval]
          end
          out
        end

        # for Postgres
        def currval(name)
          quoted_name = quote(name.to_s)
          out = nil
          fetch("SELECT currval(#{quoted_name})") do |row|
            out = row[:currval]
          end
          out
        rescue Sequel::DatabaseError => e
          # We exclude dependence on the postgresql constraint.
          if e.message =~ /\APG::ObjectNotInPrerequisiteState:(.)*is not yet defined in this session\n\z/
            return nextval(name)
          end

          # :nocov:
          raise e
          # :nocov:
        end

        # for MariaDB
        alias lastval currval

        def setval(name, value)
          name = quote(name.to_s)
          out = nil
          fetch("SELECT setval(#{name}, #{value})") do |row|
            out = row[:setval]
          end
          out
        end

        def set_column_default_nextval(table, column, sequence)
          sql = %(
            ALTER TABLE IF EXISTS #{table}
            ALTER COLUMN #{quote_name(column.to_s)}
            SET DEFAULT nextval(#{quote(sequence.to_s)}::regclass)
          ).strip
          run sql
        end
      end
    end
  end
end
