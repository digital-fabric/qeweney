# frozen_string_literal: true

require_relative 'helper'

class RequestInfoTest < MiniTest::Test
  def test_uri
    r = QNA.mock(':path' => '/test/path')
    assert_equal '/test/path', r.path
    assert_equal({}, r.query)

    r = QNA.mock(':path' => '/test/path?a=1&b=2&c=3%2f4')
    assert_equal '/test/path', r.path
    assert_equal({ a: '1', b: '2', c: '3/4' }, r.query)
  end

  def test_host
    r = QNA.mock(':path' => '/')
    assert_nil r.host

    r = QNA.mock('host' => 'my.example.com')
    assert_equal 'my.example.com', r.host
  end
end
