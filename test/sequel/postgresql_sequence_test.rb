# frozen_string_literal: true

require 'postgresql_test_helper'

class PostgresqlSequenceTest < Minitest::Test
  include PostgresqlTestHelper

  setup do
    recreate_table
  end

  test 'adds sequence with default values' do
    Sequel.migration do
      up do
        # create_sequence :position, {start: 1, increment: 1} - default values
        create_sequence :position
      end
    end.apply(PostgresqlDB, :up)

    assert_equal 1, PostgresqlDB.nextval('position')
    assert_equal 2, PostgresqlDB.nextval('position')
  end

  test 'adds sequence reader within inherited class' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(PostgresqlDB, :up)

    assert_equal 1, InheritedThing.db.nextval(:position)
    assert_equal 2, InheritedThing.db.nextval(:position)
  end

  test 'adds sequence starting at 100' do
    Sequel.migration do
      up do
        create_sequence :position, start: 100
      end
    end.apply(PostgresqlDB, :up)

    assert_equal 100, Thing.db.nextval(:position)
    assert_equal 101, Thing.db.nextval(:position)
  end

  test 'adds sequence incremented by 2' do
    Sequel.migration do
      up do
        create_sequence :position, increment: 2
      end
    end.apply(PostgresqlDB, :up)

    assert_equal 1, Thing.db.nextval(:position)
    assert_equal 3, Thing.db.nextval(:position)
  end

  test 'adds sequence incremented by 2 (using :step alias)' do
    Sequel.migration do
      up do
        create_sequence :position, step: 2
      end
    end.apply(PostgresqlDB, :up)

    assert_equal 1, Thing.db.nextval(:position)
    assert_equal 3, Thing.db.nextval(:position)
  end

  test 'returns current (or last as alias) sequence value without incrementing it' do
    Sequel.migration do
      up do
        create_sequence :position, start: 2, increment: 2
      end
    end.apply(PostgresqlDB, :up)

    Thing.db.nextval(:position)

    assert_equal 2, Thing.db.currval(:position)
    assert_equal 2, Thing.db.lastval(:position)
    assert_equal 2, Thing.db.currval(:position)
    assert_equal 2, Thing.db.lastval(:position)
  end

  test 'sets sequence value' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(PostgresqlDB, :up)

    Thing.db.nextval(:position)
    assert_equal Thing.db.currval(:position), 1

    Thing.db.setval(:position, 101)
    assert_equal 101, Thing.db.currval(:position)
  end

  test 'drops sequence and check_sequences' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(PostgresqlDB, :up)

    sequence = PostgresqlDB.check_sequences.find_all do |seq|
      seq[:sequence_name] == 'position'
    end

    assert_equal 1, sequence.size

    Sequel.migration do
      down do
        drop_sequence :position
      end
    end.apply(PostgresqlDB, :down)

    sequence = PostgresqlDB.check_sequences.find do |seq|
      seq[:sequence_name] == 'position'
    end

    assert_nil sequence
  end

  test 'orders sequences' do
    list = PostgresqlDB.check_sequences.map { |s| s[:sequence_name] }
    assert !list.include?('a')
    assert !list.include?('b')
    assert !list.include?('c')

    Sequel.migration do
      up do
        drop_table :things, if_exists: true
        # drop_table :masters, if_exists: true
        create_sequence :c
        create_sequence :a
        create_sequence :b
      end
    end.apply(PostgresqlDB, :up)

    list = PostgresqlDB.check_sequences.map { |s| s[:sequence_name] }
    assert list.include?('a')
    assert list.include?('b')
    assert list.include?('c')
  end

  test 'checks custom sequence generated from code' do
    assert_equal PostgresqlDB.custom_sequence?(:c), false

    Sequel.migration do
      up do
        create_sequence :c
      end
    end.apply(PostgresqlDB, :up)

    assert_equal PostgresqlDB.custom_sequence?(:c), true
  end

  test 'creates table that references sequence' do
    Sequel.migration do
      up do
        drop_table :masters, if_exists: true
        create_sequence :position_id, if_exists: false
        create_table :masters do
          primary_key :id
          String :name, text: true

          # PostgreSQL uses bigint as the sequence's default type.
          Bignum :position, null: false
        end
        set_column_default_nextval :masters, :position, :position_id
      end
    end.apply(PostgresqlDB, :up)

    master1 = Master.create(name: 'MASTER 1')
    pos1 = PostgresqlDB.currval(:position_id)
    assert_equal pos1, master1.reload.position

    master2 = Master.create(name: 'MASTER 2')
    pos2 = PostgresqlDB.currval(:position_id)
    assert_equal pos2, master2.reload.position

    assert_equal pos2 - pos1, 1
  end
end
