# frozen_string_literal: true

require_relative 'helper'

class MockAdapterTest < Minitest::Test
  def test_mock_adapter
    adapter = Qeweney::MockAdapter.new(nil)
    req = Qeweney::Request.new({ ':path' => '/foo' }, adapter)
    req.respond('bar', 'Content-Type' => 'baz')

    assert_equal 'bar', adapter.body
    assert_equal({'Content-Type' => 'baz'}, adapter.headers)
  end

  def test_mock_adapter_with_body
    adapter = Qeweney::MockAdapter.new('barbaz')
    req = Qeweney::Request.new({ ':path' => '/foo' }, adapter)
    assert_equal false, req.complete?

    body = req.read
    assert_equal 'barbaz', body
    assert_equal true, req.complete?
  end

  def test_mock_adapter_with_chunked_body
    adapter = Qeweney::MockAdapter.new(['bar', 'baz'])
    req = Qeweney::Request.new({ ':path' => '/foo' }, adapter)
    assert_equal false, req.complete?

    chunk = req.next_chunk
    assert_equal 'bar', chunk
    assert_equal false, req.complete?

    chunk = req.next_chunk
    assert_equal 'baz', chunk
    assert_equal true, req.complete?
  end

  def test_mock_adapter_each_chunk
    chunks = []
    adapter = Qeweney::MockAdapter.new(['bar', 'baz'])
    req = Qeweney::Request.new({ ':path' => '/foo' }, adapter)
    assert_equal false, req.complete?

    req.each_chunk { chunks << _1 }
    assert_equal ['bar', 'baz'], chunks
    assert_equal true, req.complete?
  end
end
