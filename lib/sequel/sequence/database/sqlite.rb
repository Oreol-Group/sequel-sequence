# frozen_string_literal: true

# https://sequel.jeremyevans.net/rdoc/files/doc/sql_rdoc.html
# https://github.com/jeremyevans/sequel/blob/master/lib/sequel/database/connecting.rb
module Sequel
  module Sequence
    module Database
      module SQLite
        def check_sequences
          fetch('SELECT * FROM `sqlite_sequence`;').all.to_a
        end

        def create_sequence(name, options = {})
          check_options(options)
          if_exists = build_exists_condition(options[:if_exists])
          start_option = options[:start] || 1
          num_label = options[:numeric_label] || 0
          return if (current = lastval(name)) && (current >= start_option)

          sql = [create_sequence_table(stringify(name), if_exists)]
          sql << insert_into_sequence_table_init_values(stringify(name), start_option, num_label)
          run(sql.join("\n"))
        end

        def drop_sequence(name, options = {})
          if_exists = build_exists_condition(options[:if_exists])
          run(drop_sequence_table(stringify(name), if_exists))
        end

        def nextval(name)
          run(insert_into_sequence_table(stringify(name), 0))
          take_seq(stringify(name))
        end

        def nextval_with_label(name, num_label = 0)
          run(insert_into_sequence_table(stringify(name), num_label))
          take_seq(stringify(name))
        end

        def lastval(name)
          take_seq(stringify(name))
        end

        alias currval lastval

        def setval(name, value)
          current = lastval(stringify(name))
          if current.nil?
            create_sequence(stringify(name), { start: value })
          elsif value < current
            log_info DANGER_OPT_ID
            value = current
          else
            run(update_sqlite_sequence(stringify(name), value))
          end
          value
        end

        def set_column_default_nextval(table, column, sequence)
          run(create_sequenced_column(stringify(table),
                                      stringify(column),
                                      stringify(sequence)))
        end

        private

        def stringify(name)
          @name ||= {}
          @name.fetch(name, nil) || (@name[name] = name.to_s)
        end

        def take_seq(name)
          out = nil
          fetch(select_max_seq(name)) do |row|
            out = row[:id]
          end
          out
        end

        def create_sequence_table(name, if_exists = nil)
          %(
            CREATE TABLE #{if_exists || IF_NOT_EXISTS} #{name}
            (id integer primary key autoincrement, fiction integer);
          )
        end

        def insert_into_sequence_table_init_values(name, start_id, num_label)
          "INSERT INTO #{name} (id, fiction) VALUES (#{start_id}, #{num_label});"
        end

        def insert_into_sequence_table(name, num_label)
          "INSERT INTO #{name} (fiction) VALUES (#{num_label});"
        end

        def update_sqlite_sequence(name, value)
          %(
            UPDATE sqlite_sequence
            SET seq = #{value}
            WHERE name = '#{name}';
          )
        end

        def drop_sequence_table(name, if_exists = nil)
          "DROP TABLE #{if_exists || IF_EXISTS} #{name};"
        end

        def select_max_seq(name)
          "SELECT MAX(seq) AS id FROM sqlite_sequence WHERE name = '#{name}';"
        end

        def create_sequenced_column(table, column, sequence)
          %(
            CREATE TRIGGER IF NOT EXISTS #{table}_#{sequence} AFTER INSERT
            ON #{table}
            BEGIN
              INSERT INTO #{sequence} (fiction) VALUES (0);
              UPDATE #{table}
              SET #{column} = (SELECT MAX(seq) FROM sqlite_sequence WHERE name = '#{sequence}')
              WHERE rowid = NEW.rowid;
            END;
          )
        end
      end
    end
  end
end
