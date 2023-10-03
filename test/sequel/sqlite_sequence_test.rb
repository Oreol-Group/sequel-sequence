# frozen_string_literal: true

require 'sqlite_test_helper'

class SqliteSequenceTest < Minitest::Test
  include SqliteTestHelper

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

    assert_equal 2, SQLiteDB.nextval(:position)
    assert_equal 3, SQLiteDB.nextval(:position)
  end

  test 'adds sequence reader within model and its inherited class' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    class Object < Sequel::Model; end

    assert_equal 2, Object.db.nextval('position')
    assert_equal 3, Object.db.nextval('position')

    class InheritedObject < Object; end

    assert_equal 4, InheritedObject.db.nextval(:position)
    assert_equal 5, InheritedObject.db.nextval(:position)
  end

  test 'adds sequence starting at 100' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal 101, SQLiteDB.nextval(:position)
    assert_equal 102, SQLiteDB.nextval(:position)
  end

  test 'adds a sequence that we are trying to increase by a value greater than 1' do
    @step = 4
    with_migration do
      def up
        create_sequence :position, increment: 4
      end
    end.up

    assert_equal 2, SQLiteDB.nextval(:position)
    assert_equal 3, SQLiteDB.nextval(:position)
    assert_operator (2 + @step), :>, SQLiteDB.nextval(:position)
  end

  test 'adds a sequence that we are trying to increase by a value greater than 1 (using :step alias)' do
    @step = 4
    with_migration do
      def up
        create_sequence :position, step: 4
      end
    end.up

    assert_equal 2, SQLiteDB.nextval(:position)
    assert_equal 3, SQLiteDB.nextval(:position)
    assert_operator (2 + @step), :>, SQLiteDB.nextval(:position)
  end

  test %( returns current/last sequence value, which doesn't increase by itself
          for migration WITHOUT 'start' or 'increment' values ) do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    # catch the 'start' value 'by default
    assert_equal 1, SQLiteDB.currval(:position)
    assert_equal 1, SQLiteDB.lastval(:position)

    SQLiteDB.nextval(:position)

    assert_equal 2, SQLiteDB.currval(:position)
    assert_equal 2, SQLiteDB.lastval(:position)
  end

  test %( returns current/last sequence value, which doesn't increase by itself
          for migration WITH 'start' and 'increment' values ) do
    with_migration do
      def up
        create_sequence :position, start: 2, increment: 3
      end
    end.up

    # catch the 'start' value
    assert_equal 2, SQLiteDB.currval(:position)
    assert_equal 2, SQLiteDB.lastval(:position)

    SQLiteDB.nextval(:position)

    # Doesn't support 'increment' value
    assert_equal 3, SQLiteDB.currval(:position)
    assert_equal 3, SQLiteDB.lastval(:position)
  end

  test 'sets a new sequence value greater than the current one' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    assert_equal SQLiteDB.currval(:position), 1

    SQLiteDB.nextval(:position)
    assert_equal SQLiteDB.currval(:position), 2

    SQLiteDB.setval(:position, 101)
    assert_equal 101, SQLiteDB.lastval(:position)

    SQLiteDB.nextval(:position)
    assert_equal 102, SQLiteDB.lastval(:position)
  end

  test 'sets a new sequence value less than the current one (does not change the value)' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal SQLiteDB.currval(:position), 100

    SQLiteDB.nextval(:position)
    assert_equal SQLiteDB.currval(:position), 101

    SQLiteDB.setval(:position, 1)
    assert_equal 101, SQLiteDB.lastval(:position)

    assert_equal 102, SQLiteDB.nextval(:position)
  end

  test 'sets a new sequence value with a label' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    SQLiteDB.nextval(:position)
    SQLiteDB.nextval_with_label(:position, 1)
    SQLiteDB.nextval_with_label(:position, 1)
    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position where fiction = 1;').all.size
    assert_equal 2, fiction_set_size

    # create_sequence + nextval
    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position where fiction = 0;').all.size
    assert_equal 2, fiction_set_size
  end

  test 'drops the sequence and the check_sequences' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    sequence = SQLiteDB.check_sequences.find_all do |seq|
      seq[:name] == 'position'
    end

    assert_equal 1, sequence.size

    with_migration do
      def down
        drop_sequence :position
      end
    end.down

    sequence = (list = SQLiteDB.check_sequences).empty? ? nil : list

    assert_nil sequence
  end

  test 'drops the sequence with the parameter if_exists' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    sequence = SQLiteDB.check_sequences.find_all do |seq|
      seq[:name] == 'position'
    end

    assert_equal 1, sequence.size

    with_migration do
      def down
        drop_sequence :position, if_exists: true
      end
    end.down

    sequence = (list = SQLiteDB.check_sequences).empty? ? nil : list

    assert_nil sequence
  end

  test 'orders sequences' do
    with_migration do
      def up
        drop_table :objects, if_exists: true
      end
    end.up

    list = SQLiteDB.check_sequences.map { |s| s[:name] }
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

    list = SQLiteDB.check_sequences.map { |s| s[:name] }
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

    assert_equal 1, SQLiteDB.currval(:position_id)

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size

    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 1, SQLiteDB.currval(:position_id)

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size
  end

  test 'recreates the same sequence with a smaller start value' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 100
      end
    end.up

    assert_equal 100, SQLiteDB.currval(:position_id)

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size

    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 100, SQLiteDB.currval(:position_id)

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size
  end

  test 'recreates the same sequence with a greater start value' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
      end
    end.up

    assert_equal 1, SQLiteDB.currval(:position_id)

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 1, fiction_set_size

    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 100
      end
    end.up

    assert_equal 100, SQLiteDB.currval(:position_id)

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position_id where fiction = 0;').all.size
    assert_equal 2, fiction_set_size
  end

  test 'creates table that references sequence' do
    with_migration do
      def up
        create_sequence :position_id, if_exists: false, start: 1
        create_table :apprentices do
          primary_key :id
          String :name, text: true
          Bignum :position
        end
        set_column_default_nextval :apprentices, :position, :position_id
      end
    end.up

    class Apprentice < Sequel::Model; end

    apprentice1 = Apprentice.create(name: 'Apprentice 1')
    pos1 = SQLiteDB.lastval(:position_id) - 1
    assert_equal pos1, apprentice1.reload.position

    apprentice2 = Apprentice.create(name: 'Apprentice 2')
    pos2 = SQLiteDB.currval(:position_id) - 1
    assert_equal pos2, apprentice2.reload.position

    assert_equal pos2 - pos1, 1

    SQLiteDB.nextval(:position_id)

    apprentice4 = Apprentice.create(name: 'Apprentice 4')
    pos4 = SQLiteDB.currval(:position_id) - 1
    assert_equal pos4, apprentice4.reload.position

    assert_equal pos4 - pos2, 2
  end

  test 'checks custom sequence generated from code' do
    assert_equal SQLiteDB.custom_sequence?(:c), false

    with_migration do
      def up
        create_sequence :c
      end
    end.up

    assert_equal SQLiteDB.custom_sequence?(:c), true
  end

  test 'creates a Sequence by calling DB.setval(position, 1) if it still does not exist' do
    assert !sequence_table_exists?('position')

    SQLiteDB.setval(:position, 100)
    assert_equal 100, SQLiteDB.currval(:position)
  end
end
