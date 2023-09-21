# sequel-sequence

[![CI](https://github.com/oreol-group/sequel-sequence/actions/workflows/ci.yml/badge.svg)](https://github.com/oreol-group/sequel-sequence)
[![Gem](https://img.shields.io/gem/v/sequel-sequence.svg)](https://rubygems.org/gems/sequel-sequence)
[![Downloads total](https://img.shields.io/gem/dt/sequel-sequence.svg)](https://rubygems.org/profiles/it_architect)
[![Code Climate](https://codeclimate.com/github/Oreol-Group/sequel-sequence.svg)](https://codeclimate.com/github/Oreol-Group/sequel-sequence)

Adds a useful interface and support for PostgreSQL and MySQL `SEQUENCE` on Sequel migrations. Gem includes functionality to cover the needs of SQLite users as well.

## Installation

```bash
gem install sequel-sequence
```

Or add the following line to your project's Gemfile:

```ruby
gem "sequel-sequence"
```

## Usage with PostgreSQL and MariaDB

To create a `SEQUENCE`, just use the method `create_sequence`.

```ruby
Sequel.migration do
  up do
    create_sequence :position, if_exists: false
  end

  down do
    drop_sequence :position
  end
end
```

You can also specify the initial value and increment:

```ruby
create_sequence :position, increment: 2
create_sequence :position, start: 100
create_sequence :position, if_exists: false
```

To define a column that has a sequence as its default value, use something like the following:

```ruby
Sequel.migration do
  change do
    create_sequence :position_id, if_exists: false, start: 1

    create_table(:things) do
      primary_key :id
      String :name, text: true

      # PostgreSQL uses bigint as the sequence's default type.
      Bignum :position

      Time :created_at, null: false
      Time :updated_at, null: false
    end

    set_column_default_nextval :things, :position, :position_id
  end
end
```

This gem also adds a few helpers to interact with `SEQUENCE`s.

```ruby
DB = Sequel.connect('...')
# Advance sequence and return new value
DB.nextval("position")

# Return value most recently obtained with nextval for specified sequence, either
DB.currval("position")
# or
DB.lastval("position")
# Both options are acceptable in PostgreSQL and MySQL.

# Set sequence's current value. It must be greater than lastval or currval.
DB.setval("position", 1234)
```

## Usage with SQLite

In SQLite, the sequence functionality is implemented by registering tables in the database with a primary key of `id` and an additional integer field `fiction`.
```sql
CREATE TABLE `name_of_your_sequence_table`
(id integer primary key autoincrement, fiction integer);
```

You might utilize the last one as a numeric label to collect statistics on the operation of the end-to-end counter `"name_of_your_sequence_table".id` within the application. 

```ruby
DB.nextval_with_label("position", 1)
```

By default, `fiction` has a zero value.

Otherwise, the operation of this gem for SQLite is identical to the ways of using Sequence in more advanced databases.

## Maintainer

- [Nikolai Bocharov](https://github.com/oreol-group)

## Contributors

- https://github.com/oreol-group/sequel-sequence/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/oreol-group/sequel-sequence/blob/master/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/oreol-group/sequel-sequence/blob/master/LICENSE.md.

## Code of Conduct

Everyone interacting in the sequel-sequence project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/oreol-group/sequel-sequence/blob/master/CODE_OF_CONDUCT.md).
