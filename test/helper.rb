# frozen_string_literal: true

require 'bundler/setup'
require 'qeweney'
require 'qeweney/mock_adapter'
require 'fileutils'
require 'minitest/autorun'

require_relative './coverage' if ENV['COVERAGE']
