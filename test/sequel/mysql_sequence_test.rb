# frozen_string_literal: true

require 'mysql_test_helper'

class MysqlSequenceTest < Minitest::Test
  include MysqlTestHelper

  setup do
    recreate_table
  end

  test 'adds sequence with default values' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(MysqlDB, :up)

    assert_equal 1, Ware.db.nextval(:position)
    assert_equal 2, Ware.db.nextval(:position)
  end

  test 'adds sequence reader within inherited class' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(MysqlDB, :up)

    assert_equal 1, InheritedWare.db.nextval(:position)
    assert_equal 2, InheritedWare.db.nextval(:position)
  end

  test 'adds sequence starting at 100' do
    Sequel.migration do
      up do
        create_sequence :position, start: 100
      end
    end.apply(MysqlDB, :up)

    assert_equal 100, Ware.db.nextval(:position)
    assert_equal 101, Ware.db.nextval(:position)
  end

  test 'adds sequence incremented by 2' do
    Sequel.migration do
      up do
        create_sequence :position, increment: 2
      end
    end.apply(MysqlDB, :up)

    assert_equal 1, Ware.db.nextval(:position)
    assert_equal 3, Ware.db.nextval(:position)
  end

  test 'adds sequence incremented by 2 (using :step alias)' do
    Sequel.migration do
      up do
        create_sequence :position, step: 2
      end
    end.apply(MysqlDB, :up)

    assert_equal 1, Ware.db.nextval(:position)
    assert_equal 3, Ware.db.nextval(:position)
  end

  test 'returns current/last sequence value without incrementing it' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(MysqlDB, :up)

    Ware.db.nextval(:position)

    assert_equal 1, Ware.db.currval(:position)
    assert_equal 1, Ware.db.lastval(:position)
    assert_equal 1, Ware.db.currval(:position)
    assert_equal 1, Ware.db.lastval(:position)
  end

  test 'sets sequence value' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(MysqlDB, :up)

    Ware.db.nextval(:position)
    assert_equal Ware.db.currval(:position), 1

    # in mariaDB, 'lastval' only works after 'nextval' rather than  'setval'
    Ware.db.setval(:position, 101)
    Ware.db.nextval(:position)
    assert_equal Ware.db.lastval(:position), 102
  end

  test 'drops sequence and check_sequences' do
    Sequel.migration do
      up do
        create_sequence :position
      end
    end.apply(MysqlDB, :up)

    sequence = MysqlDB.check_sequences.find_all do |seq|
      seq[:Tables_in_test] == 'position'
    end

    assert_equal 1, sequence.size

    Sequel.migration do
      down do
        drop_sequence :position
      end
    end.apply(MysqlDB, :down)

    sequence = MysqlDB.check_sequences.find do |seq|
      seq[:sequence_name] == 'position'
    end

    assert_nil sequence
  end

  test 'orders sequences' do
    list = MysqlDB.check_sequences.map { |s| s[:Tables_in_test] }
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
    end.apply(MysqlDB, :up)

    list = MysqlDB.check_sequences.map { |s| s[:Tables_in_test] }
    assert list.include?('a')
    assert list.include?('b')
    assert list.include?('c')
  end

  test 'creates table that references sequence' do
    Sequel.migration do
      up do
        drop_table :builders, if_exists: true
        create_sequence :position_id, if_exists: false
        create_table :builders do
          primary_key :id
          String :name, text: true

          # PostgreSQL uses bigint as the sequence's default type.
          Bignum :position, null: false
        end
        set_column_default_nextval :builders, :position, :position_id
      end
    end.apply(MysqlDB, :up)

    builder1 = Builder.create(name: 'Builder 1')
    pos1 = MysqlDB.currval(:position_id)
    assert_equal pos1, builder1.reload.position

    builder2 = Builder.create(name: 'Builder 2')
    pos2 = MysqlDB.currval(:position_id)
    assert_equal pos2, builder2.reload.position

    assert_equal pos2 - pos1, 1
  end
end
