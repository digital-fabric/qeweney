# frozen_string_literal: true

require 'bundler/setup'
require 'qeweney'

require 'fileutils'

require_relative './coverage' if ENV['COVERAGE']

require 'minitest/autorun'
require 'minitest/reporters'

module Qeweney
  def self.mock(headers)
    Request.new(headers, nil)
  end
end

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new
]
