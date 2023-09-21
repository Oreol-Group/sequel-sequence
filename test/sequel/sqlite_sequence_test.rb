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
        # create_sequence :position, {start: 1, increment: 1} - default values
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

  test "returns current/last sequence value, which doesn't increase by itself" do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    SQLiteDB.nextval(:position)
    # changed value (=2) after default one (=1)

    assert_equal 2, SQLiteDB.currval(:position)
    assert_equal 2, SQLiteDB.lastval(:position)
    assert_equal 2, SQLiteDB.currval(:position)
    assert_equal 2, SQLiteDB.lastval(:position)
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

  test 'sets a new sequence value less than the current one' do
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

    SQLiteDB.nextval(:position)
    assert_equal 102, SQLiteDB.lastval(:position)
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

    fiction_set_size = SQLiteDB.fetch('SELECT * FROM position where fiction = 0;').all.size
    assert_equal 1, fiction_set_size
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

    sequence = SQLiteDB.check_sequences.find do |seq|
      seq[:name] == 'position'
    end

    assert_nil sequence
  end

  test 'dropsthe sequence with the parameter if_exists' do
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

    sequence = SQLiteDB.check_sequences.find do |seq|
      seq[:name] == 'position'
    end

    assert_nil sequence
  end

  test 'orders sequences' do
    list = SQLiteDB.check_sequences.map { |s| s[:name] }
    assert !list.include?('a')
    assert !list.include?('b')
    assert !list.include?('c')

    with_migration do
      def up
        drop_table :things, if_exists: true
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

  test 'creates table that references sequence' do
    with_migration do
      def up
        drop_table :builders, if_exists: true
        create_sequence :position_id, if_exists: false, start: 1
        create_table :builders do
          primary_key :id
          String :name, text: true
          Bignum :position
        end
        set_column_default_nextval :builders, :position, :position_id
      end
    end.up

    class Builder < Sequel::Model; end

    builder1 = Builder.create(name: 'Builder 1')
    pos1 = SQLiteDB.lastval(:position_id) - 1
    assert_equal pos1, builder1.reload.position

    builder2 = Builder.create(name: 'Builder 2')
    pos2 = SQLiteDB.currval(:position_id) - 1
    assert_equal pos2, builder2.reload.position

    assert_equal pos2 - pos1, 1

    SQLiteDB.nextval(:position_id)

    builder4 = Builder.create(name: 'Builder 4')
    pos4 = SQLiteDB.currval(:position_id) - 1
    assert_equal pos4, builder4.reload.position

    assert_equal pos4 - pos2, 2
  end
end
