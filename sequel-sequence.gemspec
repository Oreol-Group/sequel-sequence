# frozen_string_literal: true

require './lib/sequel/sequence/version'

Gem::Specification.new do |spec|
  spec.name                  = 'sequel-sequence'
  spec.version               = Sequel::Sequence::VERSION
  spec.licenses              = ['MIT']
  spec.summary               = \
    'Adds SEQUENCE support to Sequel for migrations to PostgreSQL, MariaDB, MySQL and SQLite.'
  spec.description           = <<-DES
    This gem provides a single user-friendly interface for SEQUENCE functionality
    in Postgresql and MariaDB DBMS within the Sequel ORM.
    It also models the Sequences to meet the needs of SQLite and MySQL users.
  DES
  spec.authors               = ['Nikolai Bocharov']
  spec.email                 = ['it.architect@yahoo.com']
  spec.files                 = `git ls-files -z`.split("\x0")
  spec.require_paths         = ['lib']
  spec.extra_rdoc_files      = ['README.md', 'LICENSE.md']
  spec.homepage              = 'https://rubygems.org/gems/sequel-sequence'
  spec.metadata              = {
    'source_code_uri' => 'https://github.com/oreol-group/sequel-sequence',
    'changelog_uri' => 'https://github.com/oreol-group/sequel-sequence/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/oreol-group/sequel-sequence/issues'
  }
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'sequel', '>= 5.28', '<6.0'
  spec.add_development_dependency 'bundler', '>= 2.2.4'
  spec.add_development_dependency 'minitest-utils', '~> 0.4.6'
  spec.add_development_dependency 'pry-byebug', '~> 3.10.1'
  spec.add_development_dependency 'rake', '~> 13.1.0'
  spec.add_development_dependency 'rubocop', '~> 1.62.1'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  # if RUBY_ENGINE == 'jruby'
  #   # JRuby Adapter Dependencies
  #   spec.add_development_dependency 'jdbc-mysql', '~> 8.0.17'
  #   spec.add_development_dependency 'jdbc-postgres', '~> 42.2.14'
  #   spec.add_development_dependency 'jdbc-sqlite3', '~> 3.42'
  # else
  #   # MRI/Rubinius Adapter Dependencies
  #   spec.add_development_dependency 'mysql2', '~> 0.5.3'
  #   spec.add_development_dependency 'pg', '~> 1.5.4'
  #   spec.add_development_dependency 'sqlite3', '~> 1.6.0'
  # end
end
