# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# MRI/Rubinius Adapter Dependencies
platform :ruby do
  gem 'mysql2', '~> 0.5.3'
  gem 'pg', '~> 1.5.4'
  gem 'sqlite3', '~> 1.6.0'
end

# JRuby Adapter Dependencies
platform :jruby do
  gem 'jdbc-mysql', '~> 8.0.17'
  gem 'jdbc-postgres', '~> 42.2.14'
  gem 'jdbc-sqlite3', '~> 3.42'
end
