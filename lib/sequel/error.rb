# frozen_string_literal: true

module Sequel
  (
    # Error raised when attempting to utilize an invalid adapter to SEQUENCE interface.
    MethodNotAllowed = Class.new(Error)
  ).name

  class Database
    METHOD_NOT_ALLOWED = 'Method not allowed'
  end
end
