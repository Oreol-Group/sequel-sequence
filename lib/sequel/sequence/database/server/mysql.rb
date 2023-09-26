# frozen_string_literal: true

module Mysql
  def check_sequences
    fetch('SELECT * FROM mysql_sequence;').all.to_a
  end

  def custom_sequence?(sequence_name)
    out = nil
    begin
      fetch(select_from_mysql_sequence_where(stringify(sequence_name))) do |row|
        out = row[:name]
      end
    rescue Sequel::DatabaseError
      return false
    end

    !out.nil?
  end

  def create_sequence(name, options = {})
    check_options(options)
    if_exists = build_exists_condition(options[:if_exists])
    start_option = options[:start] || 1
    num_label = options[:numeric_label] || 0
    return if (current = lastval(name)) && (current >= start_option)

    run create_sequence_table(stringify(name), if_exists)
    run insert_into_sequence_table_init_values(stringify(name), start_option, num_label)
    run create_mysql_sequence
    table_matcher { run delete_from_mysql_sequence(stringify(name)) }
    run insert_into_mysql_sequence(stringify(name), start_option)
  end

  def drop_sequence(name, options = {})
    if_exists = build_exists_condition(options[:if_exists])
    run drop_sequence_table(stringify(name), if_exists)
    table_matcher { run delete_from_mysql_sequence(stringify(name)) }
  end

  def nextval(name)
    run insert_into_sequence_table(stringify(name), 0)
    table_matcher { run delete_from_mysql_sequence(stringify(name)) }
    run insert_last_insert_id_into_mysql_sequence(stringify(name))
    take_seq(stringify(name))
  end

  def nextval_with_label(name, num_label = 0)
    run insert_into_sequence_table(stringify(name), num_label)
    table_matcher { run delete_from_mysql_sequence(stringify(name)) }
    run insert_last_insert_id_into_mysql_sequence(stringify(name))
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
      log_info Sequel::Database::DANGER_OPT_ID
      value = current
    elsif value > current
      run insert_into_sequence_table_init_values(stringify(name), value, 0)
      table_matcher { run delete_from_mysql_sequence(stringify(name)) }
      run insert_into_mysql_sequence(stringify(name), value)
    end
    value
  end

  def set_column_default_nextval(table, column, sequence)
    run create_sequenced_column(stringify(table),
                                stringify(column),
                                stringify(sequence))
    run update_sequenced_column(stringify(table),
                                stringify(column),
                                stringify(sequence))
  end

  private

  def stringify(name)
    @name ||= {}
    @name.fetch(name, nil) || (@name[name] = name.to_s)
  end

  def select_from_mysql_sequence_where(name)
    "SELECT * FROM mysql_sequence where name = '#{name}';"
  end

  def create_sequence_table(name, if_exists = nil)
    %(
      CREATE TABLE #{if_exists || Sequel::Database::IF_NOT_EXISTS} #{name}
      (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
       fiction INT);
    ).strip
  end

  def insert_into_sequence_table_init_values(name, start_id, num_label)
    "INSERT INTO #{name} (id, fiction) VALUES (#{start_id}, #{num_label});"
  end

  def create_mysql_sequence
    %(
      CREATE TABLE #{Sequel::Database::IF_NOT_EXISTS} mysql_sequence
      (name VARCHAR(40), seq INT);
    ).strip
  end

  def select_max_seq(name)
    "SELECT MAX(seq) AS id FROM mysql_sequence WHERE name = '#{name}';"
  end

  def take_seq(name)
    table_matcher do
      out = nil
      fetch(select_max_seq(name)) do |row|
        out = row[:id]
      end
      out
    end
  end

  def delete_from_mysql_sequence(name)
    "DELETE QUICK IGNORE FROM mysql_sequence WHERE name = '#{name}';"
  end

  def insert_into_mysql_sequence(name, value)
    "INSERT INTO mysql_sequence (name, seq) VALUES ('#{name}', #{value});"
  end

  def drop_sequence_table(name, if_exists = nil)
    "DROP TABLE #{if_exists || Sequel::Database::IF_EXISTS} #{name};"
  end

  def insert_into_sequence_table(name, num_label)
    "INSERT INTO #{name} (fiction) VALUES (#{num_label});"
  end

  def insert_last_insert_id_into_mysql_sequence(name)
    "INSERT INTO mysql_sequence (name, seq) VALUES ('#{name}', LAST_INSERT_ID());"
  end

  def create_sequenced_column(table, _column, sequence)
    %(
      CREATE TRIGGER IF NOT EXISTS #{table}_#{sequence} BEFORE INSERT
      ON #{table}
      FOR EACH ROW BEGIN
        DELETE QUICK IGNORE FROM mysql_sequence WHERE name = '#{sequence}';
        INSERT INTO #{sequence} SET fiction = 0;
        INSERT INTO mysql_sequence SET name = '#{sequence}', seq = LAST_INSERT_ID();

      END;
    ).strip
  end

  def update_sequenced_column(table, column, sequence)
    %(
      CREATE TRIGGER IF NOT EXISTS #{table}_#{column} BEFORE INSERT
      ON #{table}
      FOR EACH ROW FOLLOWS #{table}_#{sequence}
      SET NEW.#{column} = ( SELECT MAX(seq) FROM mysql_sequence WHERE name = '#{sequence}' );
    ).strip
  end

  def table_matcher(&block)
    block.call
  rescue Sequel::DatabaseError => e
    return if e.message =~ /\AMysql2::Error: Table(.)*doesn't exist\z/

    raise e
  end
end
