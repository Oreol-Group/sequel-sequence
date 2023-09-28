# frozen_string_literal: true

require 'simplecov'

# test/sequel/mariadb_sequence_test.rb
SimpleCov.command_name 'mariadb'

# test/sequel/mysql_sequence_test.rb
SimpleCov.command_name 'mysql'

# test/sequel/postgresql_sequence_test.rb
SimpleCov.command_name 'postgresql'

# test/sequel/sqlite_sequence_test.rb
SimpleCov.command_name 'sqlite'

# test/sequel/mariadb_sequence_test.rb
# test/sequel/postgresql_sequence_test.rb
# test/sequel/sqlite_sequence_test.rb
SimpleCov.command_name 'test'

SimpleCov.start

require 'bundler/setup'
require 'sequel'
require 'sequel/extensions/migration'
require 'sequel/sequence'
require 'minitest/utils'
require 'minitest/autorun'
