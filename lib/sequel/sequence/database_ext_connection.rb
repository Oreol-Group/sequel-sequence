# frozen_string_literal: true

require_relative 'database/server/mysql'
require_relative 'database/server/mariadb'

module Sequel
  class Database
    class << self
      attr_reader :dbms
    end

    old_connect = singleton_method(:connect)

    define_singleton_method(:connect) do |*args|
      db = old_connect.call(*args)
      if db.adapter_scheme == :mysql2
        @dbms = db.mariadb? ? Mariadb : Mysql
        puts "Sequel::Database.REconnect mariadb? = #{db.mariadb?.inspect}"
        puts "Sequel::Database.REconnect server_version = #{db.server_version.inspect}"
        Sequel::Mysql2::Database.include(@dbms)
      end
      db
    end
  end
end
