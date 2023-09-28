# frozen_string_literal: true

require 'simplecov'

SimpleCov.start

require 'bundler/setup'
require 'sequel'
require 'sequel/extensions/migration'
require 'sequel/sequence'
require 'minitest/utils'
require 'minitest/autorun'
