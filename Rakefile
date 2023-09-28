# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/sequel/postgresql_sequence_test.rb',
                          'test/sequel/mariadb_sequence_test.rb',
                          'test/sequel/sqlite_sequence_test.rb',
                          'test/sequel/mock_sequence_test.rb']
end

Rake::TestTask.new(:mysql) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/sequel/mysql_sequence_test.rb']
end

Rake::TestTask.new(:postgresql) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/sequel/postgresql_sequence_test.rb']
end

Rake::TestTask.new(:mariadb) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/sequel/mariadb_sequence_test.rb']
end

Rake::TestTask.new(:sqlite) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/sequel/sqlite_sequence_test.rb']
end

Rake::TestTask.new(:mock) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/sequel/mock_sequence_test.rb']
end

RuboCop::RakeTask.new

task default: %i[test rubocop]
