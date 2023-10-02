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

## v0.4.2 - 2023-10-02

- [Added] Additions into README.md.
- [Added] Exclusion of dependence on the Postgresql constraint for "PG::The object is not in the required state P: ERROR:  currval of sequence "name_of_sequence" is not yet defined in this session".
- [Added] `custom_sequence?` method for MariaDB and SQLite.
- [Fixed] Dependencies on gems by moving them from .gemspec to Gemfile
- [Fixed] `currval` for initial state of sequence in Postgresql
- [Fixed] `lastval` for initial state of sequence in MariaDB
- [Changed] The default action `setval` for MariaDB to invoke `setval` if necessary

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
