# frozen_string_literal: true

require './lib/sequel/sequence/version'

Gem::Specification.new do |spec|
  spec.name                  = 'sequel-sequence'
  spec.version               = Sequel::Sequence::VERSION
  spec.licenses              = ['MIT']
  spec.summary               = \
    "Add support for PostgreSQL's and MySQL's SEQUENCE on Sequel migrations."
  spec.description           = <<-DES
    This gem provides a single interface for SEQUENCE functionality
    in Postgresql and Mysql databases within the Sequel ORM.
  DES
  spec.authors               = ['Nikolai Bocharov']
  spec.email                 = ['it.architect@yahoo.com']
  spec.files                 = `git ls-files -z`.split("\x0")
  spec.require_paths         = ['lib']
  spec.extra_rdoc_files      = ['README.md']
  spec.homepage              = 'https://rubygems.org/gems/sequel-sequence'
  spec.metadata              = {
    'source_code_uri' => 'https://github.com/oreol-group/sequel-sequence',
    'changelog_uri' => 'https://github.com/oreol-group/sequel-sequence/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/oreol-group/sequel-sequence/issues'
  }
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'sequel'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest-utils'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  if RUBY_ENGINE == 'jruby'
    # JRuby Adapter Dependencies
    spec.add_development_dependency 'jdbc-mysql'
    spec.add_development_dependency 'jdbc-postgres'
  else
    # MRI/Rubinius Adapter Dependencies
    spec.add_development_dependency 'mysql2'
    spec.add_development_dependency 'pg'
  end
end
