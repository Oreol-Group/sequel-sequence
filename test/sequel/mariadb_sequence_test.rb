# frozen_string_literal: true

require 'mariadb_test_helper'

class MariadbSequenceTest < Minitest::Test
  include MariadbTestHelper

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

    assert_equal 1, MariaDB.nextval(:position)
    assert_equal 2, MariaDB.nextval(:position)
  end

  test 'adds sequence reader within model and its inherited class' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    class Ware < Sequel::Model; end

    assert_equal 1, Ware.db.nextval('position')
    assert_equal 2, Ware.db.nextval('position')

    class InheritedWare < Ware; end

    assert_equal 3, InheritedWare.db.nextval(:position)
    assert_equal 4, InheritedWare.db.nextval(:position)
  end

  test 'adds sequence starting at 100' do
    with_migration do
      def up
        create_sequence :position, start: 100
      end
    end.up

    assert_equal 100, MariaDB.nextval(:position)
    assert_equal 101, MariaDB.nextval(:position)
  end

  test 'adds sequence incremented by 2' do
    with_migration do
      def up
        create_sequence :position, increment: 2
      end
    end.up

    assert_equal 1, MariaDB.nextval(:position)
    assert_equal 3, MariaDB.nextval(:position)
  end

  test 'adds sequence incremented by 2 (using :step alias)' do
    with_migration do
      def up
        create_sequence :position, step: 2
      end
    end.up

    assert_equal 1, MariaDB.nextval(:position)
    assert_equal 3, MariaDB.nextval(:position)
  end

  test "returns current/last sequence value, which doesn't increase by itself" do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    MariaDB.nextval(:position)

    assert_equal 1, MariaDB.currval(:position)
    assert_equal 1, MariaDB.lastval(:position)
    assert_equal 1, MariaDB.currval(:position)
    assert_equal 1, MariaDB.lastval(:position)
  end

  test 'sets sequence value' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    MariaDB.nextval(:position)
    assert_equal MariaDB.currval(:position), 1

    MariaDB.setval(:position, 101)
    # in MariaDB, 'lastval' only works after 'nextval' rather than  'setval'
    assert_equal 1, MariaDB.lastval(:position)

    MariaDB.nextval(:position)
    # now the value is correct
    assert_equal 102, MariaDB.lastval(:position)
  end

  test 'drops sequence and check_sequences' do
    with_migration do
      def up
        create_sequence :position
      end
    end.up

    sequence = MariaDB.check_sequences.find_all do |seq|
      seq[:Tables_in_test] == 'position'
    end

    assert_equal 1, sequence.size

    with_migration do
      def down
        drop_sequence :position
      end
    end.down

    sequence = MariaDB.check_sequences.find do |seq|
      seq[:Tables_in_test] == 'position'
    end

    assert_nil sequence
  end

  test 'orders sequences' do
    list = MariaDB.check_sequences.map { |s| s[:Tables_in_test] }
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

    list = MariaDB.check_sequences.map { |s| s[:Tables_in_test] }
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
          Bignum :position, null: false
        end
        set_column_default_nextval :builders, :position, :position_id
      end
    end.up

    class Builder < Sequel::Model; end

    builder1 = Builder.create(name: 'Builder 1')
    pos1 = MariaDB.currval(:position_id)
    assert_equal pos1, builder1.reload.position

    builder2 = Builder.create(name: 'Builder 2')
    pos2 = MariaDB.currval(:position_id)
    assert_equal pos2, builder2.reload.position

    assert_equal pos2 - pos1, 1
  end
end