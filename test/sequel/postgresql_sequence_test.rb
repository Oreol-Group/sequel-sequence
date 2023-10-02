# frozen_string_literal: true

require 'postgresql_test_helper'

class PostgresqlSequenceTest < Minitest::Test
  include PostgresqlTestHelper

  setup do
    recreate_table
  end

  test 'adds sequence with default values' do
    with_migration do
      def up
        # create_sequence :position, {start: 1, increment: 1} - default values
        create_sequence :position
      end
    end.up

    assert_equal 1, PostgresqlDB.nextval('position')
    assert_equal 2, PostgresqlDB.nextval('position')
  end

  test 'adds sequence reader within model and its inherited class' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    class Thing < Sequel::Model; end

    assert_equal 1, Thing.db.nextval('position')
    assert_equal 2, Thing.db.nextval('position')

    class InheritedThing < Thing; end

    assert_equal 3, InheritedThing.db.nextval(:position)
    assert_equal 4, InheritedThing.db.nextval(:position)
  end

  test 'adds sequence starting at 100' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal 100, PostgresqlDB.nextval(:position)
    assert_equal 101, PostgresqlDB.nextval(:position)
  end

  test 'adds sequence incremented by 2' do
    with_migration do
      def up
        create_sequence :position, increment: 2
      end
    end.up

    assert_equal 1, PostgresqlDB.nextval(:position)
    assert_equal 3, PostgresqlDB.nextval(:position)
  end

  test 'adds sequence incremented by 2 (using :step alias)' do
    with_migration do
      def up
        create_sequence :position, step: 2
      end
    end.up

    assert_equal 1, PostgresqlDB.nextval(:position)
    assert_equal 3, PostgresqlDB.nextval(:position)
  end

  test %( returns current/last sequence value, which doesn't increase by itself
          for migration WITHOUT 'start' or 'increment' values ) do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    # catch the 'start' value
    assert_equal 1, PostgresqlDB.currval(:position)
    # is the same value
    assert_equal 1, PostgresqlDB.lastval(:position)

    PostgresqlDB.nextval(:position)

    assert_equal 2, PostgresqlDB.currval(:position)
    assert_equal 2, PostgresqlDB.lastval(:position)
  end

  test %( returns current/last sequence value, which doesn't increase by itself
          for migration WITH 'start' and 'increment' values ) do
    with_migration do
      def up
        create_sequence :position, start: 2, increment: 3
      end
    end.up

    # catch the 'start' value
    assert_equal 2, PostgresqlDB.currval(:position)
    # is the same value
    assert_equal 2, PostgresqlDB.lastval(:position)

    PostgresqlDB.nextval(:position)

    # support 'increment' value
    assert_equal 5, PostgresqlDB.currval(:position)
    assert_equal 5, PostgresqlDB.lastval(:position)
  end

  test 'sets a new sequence value greater than the current one' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    assert_equal PostgresqlDB.currval(:position), 1

    PostgresqlDB.nextval(:position)
    assert_equal PostgresqlDB.currval(:position), 2

    PostgresqlDB.setval(:position, 101)
    assert_equal 101, PostgresqlDB.lastval(:position)

    assert_equal 102, PostgresqlDB.nextval(:position)
  end

  test 'sets a new sequence value less than the current one (change the value as an EXCEPTION)' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal PostgresqlDB.currval(:position), 100

    PostgresqlDB.nextval(:position)
    assert_equal PostgresqlDB.currval(:position), 101

    PostgresqlDB.setval(:position, 1)
    assert_equal 1, PostgresqlDB.lastval(:position)

    PostgresqlDB.nextval(:position)
    assert_equal 2, PostgresqlDB.lastval(:position)
  end

  test 'drops sequence and check_sequences' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    sequence = PostgresqlDB.check_sequences.find_all do |seq|
      seq[:sequence_name] == 'position'
    end

    assert_equal 1, sequence.size

    with_migration do
      def down
        drop_sequence :position
      end
    end.down

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

    with_migration do
      def up
        drop_table :things, if_exists: true
        create_sequence :c
        create_sequence :a
        create_sequence :b
      end
    end.up

    list = PostgresqlDB.check_sequences.map { |s| s[:sequence_name] }
    assert list.include?('a')
    assert list.include?('b')
    assert list.include?('c')
  end

  test 'checks custom sequence generated from code' do
    assert_equal PostgresqlDB.custom_sequence?(:c), false

    with_migration do
      def up
        create_sequence :c
      end
    end.up

    assert_equal PostgresqlDB.custom_sequence?(:c), true
  end

  test 'creates table that references sequence' do
    with_migration do
      def up
        drop_table :masters, if_exists: true
        create_sequence :position_id, if_exists: false, start: 1
        create_table :masters, if_not_exists: true do
          primary_key :id
          String :name, text: true
          Bignum :position, null: false
        end
        set_column_default_nextval :masters, :position, :position_id
      end
    end.up

    class Master < Sequel::Model; end

    master1 = Master.create(name: 'MASTER 1')
    pos1 = PostgresqlDB.currval(:position_id)
    assert_equal pos1, master1.reload.position

    master2 = Master.create(name: 'MASTER 2')
    pos2 = PostgresqlDB.currval(:position_id)
    assert_equal pos2, master2.reload.position

    assert_equal pos2 - pos1, 1
  end
end
