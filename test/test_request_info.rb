# frozen_string_literal: true

require_relative 'helper'

class RequestInfoTest < MiniTest::Test
  def test_uri
    r = Qeweney.mock(':path' => '/test/path')
    assert_equal '/test/path', r.path
    assert_equal({}, r.query)

    r = Qeweney.mock(':path' => '/test/path?a=1&b=2&c=3%2f4')
    assert_equal '/test/path', r.path
    assert_equal({ a: '1', b: '2', c: '3/4' }, r.query)
  end

  def test_host
    r = Qeweney.mock(':path' => '/')
    assert_nil r.host

    r = Qeweney.mock('host' => 'my.example.com')
    assert_equal 'my.example.com', r.host
  end

  def test_full_uri
    r = Qeweney.mock(
      ':scheme' => 'https',
      'host' => 'foo.bar',
      ':path' => '/hey?a=b&c=d'
    )

    assert_equal 'https://foo.bar/hey?a=b&c=d', r.full_uri
  end

  def test_cookies
    r = Qeweney.mock

    assert_equal({}, r.cookies)

    r = Qeweney.mock(
      'cookie' => 'uaid=a%2Fb; lastLocus=settings; signin_ref=/'
    )

    assert_equal({
      'uaid' => 'a/b',
      'lastLocus' => 'settings',
      'signin_ref' => '/'
    }, r.cookies)
  end
end
