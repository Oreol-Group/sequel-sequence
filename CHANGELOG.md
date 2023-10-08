# Changelog

<!--
Prefix your message with one of the following:

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.
-->

## v0.5.0 - 2023-10-08

- [Fixed] The conditions of migrations were clarified and fixed in README.md.
- [Added] The `delete_to_currval(name)` method for MySQL and SQLite `SEQUENCE`-table and Exceptions for any other cases.
- [Added] The `drop_sequence?` can accept multiple arguments with condition 'IF EXISTS'.
- [Added] The `create_sequence!` drops the `SEQUENCE` if it exists before attempting to create it.
- [Changed] INT type to BIGINT type for the primery key of a MySQL `SEQUENCE`-table.
- [Added] The ext. params for the PostgreSql `SEQUENCE` ( https://www.postgresql.org/docs/current/sql-createsequence.html )
- [Added] The ext. params for the Mariadb `SEQUENCE` ( https://mariadb.com/kb/en/create-sequence )

## v0.4.2 - 2023-10-03

- [Added] Additions into README.md.
- [Added] Exclusion of dependence on the Postgresql constraint for "PG::The object is not in the required state P: ERROR:  currval of sequence "name_of_sequence" is not yet defined in this session".
- [Added] `custom_sequence?` method for MariaDB and SQLite.
- [Fixed] Dependencies on gems by moving them from .gemspec to Gemfile
- [Fixed] `currval` for initial state of sequence in Postgresql
- [Fixed] `lastval` for initial state of sequence in MariaDB
- [Changed] The default action `setval` for MariaDB to invoke `setval` if necessary
- [Changed] The class initialization algorithm in `sequence.rb` depending on the gems included in the user project.

## v0.4.1 - 2023-09-28

- [Added] Important notice to README.md.
- [Added] MySQL tests cover 100%.
- [Added] SQLite tests cover 100%.
- [Added] Mock connection to check for additional ORM exceptions.

## v0.4.0 - 2023-09-26

- [Fixed] Differences between MySQL and MariaDB.
- [Added] Gem API support for MySQL databases.
- [Changed] README.md, CONTRIBUTING.md and .gemspec description.
- [Fixed] Some API support for SQLite databases.

## v0.3.0 - 2023-09-21

- [Added] A parametrized 'IF EXISTS' condition into the drop_sequence.
- [Added] A parametrized 'IF NOT EXISTS' condition into the create_sequence.
- [Added] Gem API support for SQLite databases.
- [Fixed] Tests for the Mysql database.

## v0.2.0 - 2023-09-14

- [Added] CI features based on GitHub Actions.
- [Fixed] README.md
- [Changed] Unit tests.
- [Fixed] Sequel::Sequence::Database exceptions.

## v0.1.0 - 2023-09-10

- Initial release.
