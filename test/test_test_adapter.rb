# frozen_string_literal: true

require_relative 'helper'
require 'qeweney/test_adapter'

class TestAdapterTest < Minitest::Test
  def test_test_adapter
    adapter = Qeweney::TestAdapter.new
    req = Qeweney::Request.new({ ':path' => '/foo' }, adapter)
    req.respond('bar', 'Content-Type' => 'baz')

    assert_equal 'bar', adapter.body
    assert_equal({'Content-Type' => 'baz'}, adapter.headers)
  end
end
