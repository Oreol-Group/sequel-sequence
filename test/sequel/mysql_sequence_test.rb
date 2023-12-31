# frozen_string_literal: true

require 'mysql_test_helper'

class MysqlSequenceTest < Minitest::Test
  include MysqlTestHelper

  setup do
    recreate_table
  end

  test 'adds sequence with default values' do
    with_migration do
      def up
        # create_sequence :position, {start: 1, increment: 1, numeric_label: 0} - default values
        create_sequence :position
      end
    end.up

    assert_equal 2, MysqlDB.nextval(:position)
    assert_equal 3, MysqlDB.nextval(:position)
  end

  test 'adds sequence with numeric_label' do
    with_migration do
      def up
        # create_sequence :position, {start: 1, increment: 1, numeric_label: 0} - default values
        create_sequence :position, numeric_label: 10
      end
    end.up

    assert_equal 1, MysqlDB.currval(:position)

    fiction_list = MysqlDB.fetch('SELECT fiction FROM position;').all
    assert_equal 1, fiction_list.size
    assert_equal 10, fiction_list.first[:fiction]
  end

  test 'adds sequence reader within model and its inherited class' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    class Stuff < Sequel::Model; end

    assert_equal 2, Stuff.db.nextval('position')
    assert_equal 3, Stuff.db.nextval('position')

    class InheritedStuff < Stuff; end

    assert_equal 4, InheritedStuff.db.nextval(:position)
    assert_equal 5, InheritedStuff.db.nextval(:position)
  end

  test 'adds sequence starting at 100' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal 101, MysqlDB.nextval(:position)
    assert_equal 102, MysqlDB.nextval(:position)
  end

  test 'adds a sequence that we are trying to increase by a value greater than 1' do
    @step = 4
    with_migration do
      def up
        create_sequence :position, increment: 4
      end
    end.up

    assert_equal 2, MysqlDB.nextval(:position)
    assert_equal 3, MysqlDB.nextval(:position)
    assert_operator (2 + @step), :>, MysqlDB.nextval(:position)
  end

  test 'adds a sequence that we are trying to increase by a value greater than 1 (using :step alias)' do
    @step = 4
    with_migration do
      def up
        create_sequence :position, step: 4
      end
    end.up

    assert_equal 2, MysqlDB.nextval(:position)
    assert_equal 3, MysqlDB.nextval(:position)
    assert_operator (2 + @step), :>, MysqlDB.nextval(:position)
  end

  test %( returns current/last sequence value, which doesn't increase by itself
          for migration WITHOUT 'start' or 'increment' values ) do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    # catch the 'start' value 'by default
    assert_equal 1, MysqlDB.currval(:position)
    assert_equal 1, MysqlDB.lastval(:position)

    MysqlDB.nextval(:position)

    assert_equal 2, MysqlDB.currval(:position)
    assert_equal 2, MysqlDB.lastval(:position)
  end

  test %( returns current/last sequence value, which doesn't increase by itself
          for migration WITH 'start' and 'increment' values ) do
    with_migration do
      def up
        create_sequence :position, start: 2, increment: 3
      end
    end.up

    # catch the 'start' value
    assert_equal 2, MysqlDB.currval(:position)
    assert_equal 2, MysqlDB.lastval(:position)

    MysqlDB.nextval(:position)

    # Doesn't support 'increment' value
    assert_equal 3, MysqlDB.currval(:position)
    assert_equal 3, MysqlDB.lastval(:position)
  end

  test 'sets a new sequence value greater than the current one' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    assert_equal MysqlDB.currval(:position), 1

    MysqlDB.nextval(:position)
    assert_equal MysqlDB.currval(:position), 2

    MysqlDB.setval(:position, 101)
    assert_equal 101, MysqlDB.lastval(:position)

    assert_equal 102, MysqlDB.nextval(:position)
  end

  test 'sets a new sequence value less than the current one (does not change the value)' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal MysqlDB.currval(:position), 100

    MysqlDB.nextval(:position)
    assert_equal MysqlDB.currval(:position), 101

    MysqlDB.setval(:position, 1)
    assert_equal 101, MysqlDB.lastval(:position)

    MysqlDB.nextval(:position)
    assert_equal 102, MysqlDB.lastval(:position)
  end

  test 'sets a new sequence value with a label' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    MysqlDB.nextval(:position)
    MysqlDB.nextval_with_label(:position, 1)
    MysqlDB.nextval_with_label(:position, 1)
    fiction_set_size = MysqlDB.fetch('SELECT * FROM position where fiction = 1;').all.size
    assert_equal 2, fiction_set_size

    # create_sequence + nextval
    fiction_set_size = MysqlDB.fetch('SELECT * FROM position where fiction = 0;').all.size
    assert_equal 2, fiction_set_size
  end

  test 'drops the sequence and the check_sequences' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    sequence = MysqlDB.check_sequences.find_all do |seq|
      seq[:name] == 'position'
    end

    assert_equal 1, sequence.size

    with_migration do
      def down
        drop_sequence :position
      end
    end.down

    sequence = MysqlDB.check_sequences.find do |seq|
      seq[:name] == 'position'
    end

    assert_nil sequence
  end

  test 'drops the sequence with the parameter if_exists' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    sequence = MysqlDB.check_sequences.find_all do |seq|
      seq[:name] == 'position'
    end

    assert_equal 1, sequence.size

    with_migration do
      def down
        drop_sequence :position, if_exists: true
      end
    end.down

    sequence = MysqlDB.check_sequences.find do |seq|
      seq[:name] == 'position'
    end

    assert_nil sequence
  end

  test 'orders sequences' do
    with_migration do
      def up
        drop_table :stuffs, if_exists: true
      end
    end.up

    list = MysqlDB.check_sequences.map { |s| s[:name] }
    assert !list.include?('a')
    assert !list.include?('b')
    assert !list.include?('c')

    with_migration do
      def up
        create_sequence :c, { start: 1 }
        create_sequence :a, { start: 3 }
        create_sequence :b
      end
    end.up

    list = MysqlDB.check_sequences.map { |s| s[:name] }
    assert list.include?('a')
    assert list.include?('b')
    assert list.include?('c')
  end

  test 'recreates the same sequence with the same start value' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 1, MysqlDB.currval(:position_id)

    fiction_set_size = MysqlDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size

    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 1, MysqlDB.currval(:position_id)

    fiction_set_size = MysqlDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size
  end

  test 'recreates the same sequence with a smaller start value' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 100
      end
    end.up

    assert_equal 100, MysqlDB.currval(:position_id)

    fiction_set_size = MysqlDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size

    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 100, MysqlDB.currval(:position_id)

    fiction_set_size = MysqlDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size
  end

  test 'recreates the same sequence with a greater start value' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 1, MysqlDB.currval(:position_id)

    fiction_set_size = MysqlDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size

    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 100
      end
    end.up

    assert_equal 100, MysqlDB.currval(:position_id)

    fiction_set_size = MysqlDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 2, fiction_set_size
  end

  test 'creates table that references sequence' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
        create_table :creators do
          primary_key :id
          String :name, text: true
          Bignum :position
        end
        set_column_default_nextval :creators, :position, :position_id
      end
    end.up

    class Creator < Sequel::Model; end

    creator1 = Creator.create(name: 'Creator 1')
    pos1 = MysqlDB.lastval(:position_id)
    assert_equal pos1, creator1.reload.position

    creator2 = Creator.create(name: 'Creator 2')
    pos2 = MysqlDB.currval(:position_id)
    assert_equal pos2, creator2.reload.position

    assert_equal pos2 - pos1, 1

    MysqlDB.nextval(:position_id)

    creator4 = Creator.create(name: 'Creator 4')
    pos4 = MysqlDB.currval(:position_id)
    assert_equal pos4, creator4.reload.position

    assert_equal pos4 - pos2, 2
  end

  test 'checks custom sequence generated from code' do
    assert_equal MysqlDB.custom_sequence?(:c), false

    with_migration do
      def up
        create_sequence :c
      end
    end.up

    assert_equal MysqlDB.custom_sequence?(:c), true
  end

  test "catches a Mysql2::Error: «Table mysql_sequence doesn't exist»" do
    assert !sequence_table_exists?('position')

    MysqlDB.drop_table :mysql_sequence, if_exists: true

    last_number = MysqlDB.lastval(:position)
    assert_nil last_number
  end

  test 'creates a Sequence by calling DB.setval(position, 1) if it still does not exist' do
    assert !sequence_table_exists?('position')

    MysqlDB.setval(:position, 100)
    assert_equal 100, MysqlDB.currval(:position)
  end

  test 'deletes history from the sequence_table' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 1, MysqlDB.currval(:position_id)

    sequence_table_size = MysqlDB.fetch('SELECT count(*) as len FROM position_id;').first[:len]
    assert_equal 1, sequence_table_size

    10.times { MysqlDB.nextval(:position_id) }

    assert_equal 11, MysqlDB.currval(:position_id)

    sequence_table_size = MysqlDB.fetch('SELECT count(*) as len FROM position_id;').first[:len]
    assert_equal 11, sequence_table_size

    MysqlDB.delete_to_currval(:position_id)

    assert_equal 11, MysqlDB.currval(:position_id)

    sequence_table_size = MysqlDB.fetch('SELECT count(*) as len FROM position_id;').first[:len]
    assert_equal 1, sequence_table_size
  end

  test 'deletes sequences by "drop_sequence?"' do
    with_migration do
      def up
        create_sequence :a
        create_sequence :b
        create_sequence :c
      end
    end.up

    assert MysqlDB.custom_sequence?(:a)
    assert MysqlDB.custom_sequence?(:b)
    assert MysqlDB.custom_sequence?(:c)

    MysqlDB.drop_sequence?(:a, :b, :c, :d)

    assert !MysqlDB.custom_sequence?(:a)
    assert !MysqlDB.custom_sequence?(:b)
    assert !MysqlDB.custom_sequence?(:c)
  end

  test 'deletes if exists before creating! the sequence' do
    with_migration do
      def up
        create_sequence! :position, { start: 1000, increment: 10 }
      end
    end.up

    assert_equal 1000, MysqlDB.currval(:position)

    10.times { MysqlDB.nextval(:position) }
    assert_equal 1010, MysqlDB.currval(:position)

    MysqlDB.create_sequence!(:position, { start: 1, increment: 1 })

    assert_equal 1, MysqlDB.currval(:position)

    10.times { MysqlDB.nextval(:position) }
    assert_equal 11, MysqlDB.currval(:position)
  end

  test 'checks the BIGINT primery key for a sequence table' do
    with_migration do
      def up
        create_sequence :position, { start: 9_223_372_036_854_775_800 }
      end
    end.up

    assert_equal 9_223_372_036_854_775_800, MysqlDB.currval(:position)
    assert_equal 9_223_372_036_854_775_801, MysqlDB.nextval(:position)
  end

  test 'checks the BIGINT primery key with negative value for a sequence table (does not support)' do
    with_migration do
      def up
        create_sequence :position, { start: -9_223_372_036_854_775_807 }
      end
    end.up

    assert_equal(-9_223_372_036_854_775_807, MysqlDB.currval(:position))
    # https://www.cockroachlabs.com/docs/stable/serial#generated-values-for-modes-rowid-and-virtual_sequence
    # "...negative values are not returned."
    assert_equal 1, MysqlDB.nextval(:position)
  end
end
