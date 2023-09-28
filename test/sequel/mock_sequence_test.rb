# frozen_string_literal: true

require 'mock_test_helper'

class MockSequenceTest < Minitest::Test
  test 'checks check_options with params' do
    mocked_method = Minitest::Mock.new
    some_instance = MockDB

    mocked_method.expect :call, true, [Sequel::Database::DANGER_OPT_INCREMENT]
    some_instance.stub :log_info, mocked_method do
      some_instance.check_options({ increment: 2 })
    end
    mocked_method.verify

    mocked_method.expect :call, true, [Sequel::Database::DANGER_OPT_INCREMENT]
    some_instance.stub :log_info, mocked_method do
      some_instance.check_options({ step: 2 })
    end
    mocked_method.verify
  end

  test 'checks custom_sequence?' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.custom_sequence?(:position)
    end
  end

  test 'checks check_sequences' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.check_sequences
    end
  end

  test 'checks create_sequence' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.create_sequence(:position)
    end
  end

  test 'checks drop_sequence' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.drop_sequence(:position)
    end
  end

  test 'checks quote_name' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.quote_name(:position)
    end
  end

  test 'checks quote' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.quote(:position)
    end
  end

  test 'checks nextval_with_label' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.nextval_with_label(:position, 100)
    end
  end

  test 'checks nextval' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.nextval(:position)
    end
  end

  test 'checks currval' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.currval(:position)
    end
  end

  test 'checks lastval' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.lastval(:position)
    end
  end

  test 'checks setval' do
    assert_raises Sequel::MethodNotAllowed do
      MockDB.setval(:position, 100)
    end
  end

  test 'checks build_exists_condition for a true condition' do
    assert_equal Sequel::Database::IF_EXISTS, MockDB.build_exists_condition(true)
  end

  test 'checks build_exists_condition for a false condition' do
    assert_equal Sequel::Database::IF_NOT_EXISTS, MockDB.build_exists_condition(false)
  end

  test 'checks build_exists_condition for a non boolean condition' do
    assert_nil MockDB.build_exists_condition('')
  end
end
