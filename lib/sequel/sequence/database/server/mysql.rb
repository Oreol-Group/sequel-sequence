# frozen_string_literal: true

module Mysql
  def quote_column_name(name)
    "`#{name.gsub('`', '``')}`"
  end

  def quote_sequence_name(name)
    "`#{name.gsub(/[`"']/, '')}`"
  end

  def check_sequences
    fetch("SHOW FULL TABLES WHERE Table_type = 'SEQUENCE';").all.to_a
  end

  def create_sequence(name, options = {})
    increment = options[:increment] || options[:step]
    if_exists = build_exists_condition(options[:if_exists])
    name = quote_name(name.to_s)

    sql = ["CREATE SEQUENCE #{if_exists} #{name}"]
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
    name = quote(name.to_s)
    out = nil
    fetch("SELECT lastval(#{name});") do |row|
      out = row["lastval(#{name})".to_sym]
    end
    out
  end

  alias currval lastval

  def setval(name, value)
    name = quote(name.to_s)
    out = nil
    fetch("SELECT setval(#{name}, #{value});") do |row|
      out = row["setval(#{name}, #{value})".to_sym]
    end
    out
  end

  def set_column_default_nextval(table, column, sequence)
    table = table.to_s
    column = column.to_s
    sequence = quote(sequence.to_s)
    run "ALTER TABLE IF EXISTS #{table} " \
        "ALTER COLUMN #{column} SET DEFAULT nextval(#{sequence});"
  end
end
