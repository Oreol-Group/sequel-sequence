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
  spec.extra_rdoc_files      = ['README.md', 'LICENSE.md']
  spec.homepage              = 'https://rubygems.org/gems/sequel-sequence'
  spec.metadata              = {
    'source_code_uri' => 'https://github.com/oreol-group/sequel-sequence',
    'changelog_uri' => 'https://github.com/oreol-group/sequel-sequence/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/oreol-group/sequel-sequence/issues'
  }
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'sequel', '~> 5.28.0'
  spec.add_development_dependency 'bundler', '>= 2.2.4'
  spec.add_development_dependency 'minitest-utils', '~> 0.4.6'
  spec.add_development_dependency 'pry-byebug', '~> 3.8.0'
  spec.add_development_dependency 'rake', '~> 13.0.2'
  spec.add_development_dependency 'rubocop', '~> 1.44.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  if RUBY_ENGINE == 'jruby'
    # JRuby Adapter Dependencies
    spec.add_development_dependency 'jdbc-mysql', '~> 8.0.17'
    spec.add_development_dependency 'jdbc-postgres', '~> 42.2.14'
  else
    # MRI/Rubinius Adapter Dependencies
    spec.add_development_dependency 'mysql2', '~> 0.5.3'
    spec.add_development_dependency 'pg', '~> 1.2.0'
  end
end
