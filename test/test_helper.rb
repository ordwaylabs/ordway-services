$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

ENV['RAILS_ENV'] = 'test'

require 'ordway/services'
require 'minitest/autorun'
require 'active_support/core_ext/module/delegation'
require 'securerandom'
require 'logging/rails'
