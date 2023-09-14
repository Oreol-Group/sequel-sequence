# frozen_string_literal: true

module Sequel
  module Sequence
    module Database
      def custom_sequence?(_sequence_name)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def check_sequences
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def create_sequence(_name, _options = {})
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      def drop_sequence(_name)
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

      def nextval(_name)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      # for connection.adapter_name = "PostgreSQL"
      def currval(_name)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end

      # for connection.adapter_name = "Mysql2"
      alias lastval currval

      def setval(_name, _value)
        raise Sequel::MethodNotAllowed, Sequel::MethodNotAllowed::METHOD_NOT_ALLOWED
      end
    end
  end
end
