# frozen_string_literal: true

module Sequel
  class Database
    old_connect = singleton_method(:connect)

    define_singleton_method(:connect) do |*args|
      db = old_connect.call(*args)
      if db.adapter_scheme == :mysql2
        puts "Sequel::Database.REconnect mariadb? = #{db.mariadb?.inspect}"
        puts "Sequel::Database.REconnect server_version = #{db.server_version.inspect}"
      end
      db
    end
  end
end
