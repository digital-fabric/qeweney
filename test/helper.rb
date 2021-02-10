# frozen_string_literal: true

require 'bundler/setup'
require 'qna'

require 'fileutils'

require_relative './coverage' if ENV['COVERAGE']

require 'minitest/autorun'
require 'minitest/reporters'

module QNA
  def self.mock(headers)
    Request.new(headers, nil)
  end
end

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new
]
