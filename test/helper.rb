# frozen_string_literal: true

require 'bundler/setup'
require 'qeweney'

require 'fileutils'

require_relative './coverage' if ENV['COVERAGE']

require 'minitest/autorun'

module Qeweney
  class MockAdapter
    attr_reader :calls

    def initialize
      @calls = []
    end

    def method_missing(sym, *args)
      calls << [sym, *args]
    end
  end

  def self.mock(headers = {})
    headers[':method'] ||= ''
    headers[':path'] ||= ''
    Request.new(headers, MockAdapter.new)
  end

  class Request
    def response_calls
      adapter.calls
    end
  end
end
