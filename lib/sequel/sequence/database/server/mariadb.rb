# frozen_string_literal: true

module Sequel
  module Sequence
    module Database
      module Server
        module Mariadb
          def quote_column_name(name)
            "`#{name.gsub('`', '``')}`"
          end

          def quote_sequence_name(name)
            "`#{name.gsub(/[`"']/, '')}`"
          end

          def custom_sequence?(sequence_name)
            db = name_of_current_database
            return false if db.empty?

            sql = "SHOW FULL TABLES WHERE Table_type = 'SEQUENCE' and Tables_in_#{db} = '#{sequence_name}';"
            fetch(sql).all.size.positive?
          end

          def check_sequences
            fetch("SHOW FULL TABLES WHERE Table_type = 'SEQUENCE';").all.to_a
          end

          def create_sequence(name, options = {})
            increment = options[:increment] || options[:step]
            if_exists = build_exists_condition(options[:if_exists])
            name = quote_name(name.to_s)

            sql = ["CREATE SEQUENCE #{if_exists || Sequel::Database::IF_NOT_EXISTS} #{name}"]
            sql << "INCREMENT BY #{increment}" if increment
            sql << "START WITH #{options[:start]}" if options[:start]
            sql << ';'

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
            fetch("SELECT nextval(#{name});") do |row|
              out = row["nextval(#{name})".to_sym]
            end
            out
          end

          def lastval(name)
            quoted_name = quote(name.to_s)
            out = nil
            fetch("SELECT lastval(#{quoted_name});") do |row|
              out = row["lastval(#{quoted_name})".to_sym]
            end
            return nextval(name) if out.nil?

            out
          end

          alias currval lastval

          def setval(name, value)
            current = lastval(name)
            if value <= current
              log_info Sequel::Database::DANGER_OPT_ID if value < current
              value = current
            else
              quoted_name = quote(name.to_s)
              value -= 1
              out = nil
              fetch("SELECT setval(#{quoted_name}, #{value});") do |row|
                out = row["setval(#{quoted_name}, #{value})".to_sym]
              end
              value = nextval(name)
            end
            value
          end

          def set_column_default_nextval(table, column, sequence)
            sql = %(
              ALTER TABLE IF EXISTS #{quote(table.to_s)}
              ALTER COLUMN #{quote_name(column.to_s)}
              SET DEFAULT nextval(#{quote(sequence.to_s)})
            ).strip
            run sql
          end

          private

          def name_of_current_database
            fetch('SELECT DATABASE() AS db;').first[:db]
          end
        end
      end
    end
  end
end
