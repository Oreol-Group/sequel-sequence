# frozen_string_literal: true

module Sequel
  module Sequence
    module Database
      DANGER_OPT_ID = "Warning! The new sequence ID can't be less than the current one."
      DANGER_OPT_INCREMENT = 'Warning! Increments greater than 1 are not supported.'
      IF_EXISTS = 'IF EXISTS'
      IF_NOT_EXISTS = 'IF NOT EXISTS'

      def check_options(params)
        log_info DANGER_OPT_INCREMENT if params[:increment] && params[:increment] != 1
        log_info DANGER_OPT_INCREMENT if params[:step] && params[:step] != 1
      end

      def custom_sequence?(_sequence_name)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def check_sequences
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def create_sequence(_name, _options = {})
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def drop_sequence(_name, _options = {})
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def quote_name(name)
        unless respond_to?(:quote_column_name, false)
          raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
        end

        name.to_s.split('.', 2).map { |part| quote_column_name(part) }.join('.')
      end

      def quote(name)
        unless respond_to?(:quote_sequence_name, false)
          raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
        end

        name.to_s.split('.', 2).map { |part| quote_sequence_name(part) }.join('.')
      end

      def nextval_with_label(_name, _num_label = 0)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def nextval(_name)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      # for Postgres
      def currval(_name)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      # for MariaDB
      alias lastval currval

      def setval(_name, _value)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def build_exists_condition(option)
        case option
        when true
          IF_EXISTS
        when false
          IF_NOT_EXISTS
        end
      end
    end
  end
end
