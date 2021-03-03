# frozen_string_literal: true

require_relative 'helper'

class RoutingTest < MiniTest::Test
  App1 = ->(r) do
    r.route do
      r.on_root { r.redirect '/hello' }
      r.on('hello') do
        r.on_get('world') { r.respond 'Hello world' }
        r.on_get { r.respond 'Hello' }
        r.on_post do
          r.redirect '/'
        end
      end
    end
  end

  def test_app1
    r = Qeweney.mock(':path' => '/foo')
    App1.(r)
    assert_equal [[:respond, nil, { ':status' => 404 }]], r.response_calls

    r = Qeweney.mock(':path' => '/')
    App1.(r)
    assert_equal [[:respond, nil, { ':status' => 302, 'Location' => '/hello' }]], r.response_calls

    r = Qeweney.mock(':path' => '/hello', ':method' => 'foo')
    App1.(r)
    assert_equal [[:respond, nil, { ':status' => 404 }]], r.response_calls

    r = Qeweney.mock(':path' => '/hello', ':method' => 'get')
    App1.(r)
    assert_equal [[:respond, 'Hello', {}]], r.response_calls

    r = Qeweney.mock(':path' => '/hello', ':method' => 'post')
    App1.(r)
    assert_equal [[:respond, nil, { ':status' => 302, 'Location' => '/' }]], r.response_calls

    r = Qeweney.mock(':path' => '/hello/world', ':method' => 'get')
    App1.(r)
    assert_equal [[:respond, 'Hello world', {}]], r.response_calls
  end

  def test_on_root
    app = Qeweney.route do |r|
      r.on_root { r.respond('root') }
      r.on('foo') {
        r.on_root { r.respond('foo root') }
        r.on('bar') {
          r.on_root { r.respond('bar root') }
          r.on('baz') {
            r.on_root { r.respond('baz root') }
          }
        }
      }
    end

    r = Qeweney.mock(':path' => '/')
    app.(r)
    assert_equal [[:respond, 'root', {}]], r.response_calls

    r = Qeweney.mock(':path' => '/foo')
    app.(r)
    assert_equal [[:respond, 'foo root', {}]], r.response_calls

    r = Qeweney.mock(':path' => '/foo/bar')
    app.(r)
    assert_equal [[:respond, 'bar root', {}]], r.response_calls

    r = Qeweney.mock(':path' => '/foo/bar/baz')
    app.(r)
    assert_equal [[:respond, 'baz root', {}]], r.response_calls
  end
end
