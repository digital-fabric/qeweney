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

  def test_relative_path
    default_relative_path = nil

    app = Qeweney.route do |r|
      default_relative_path = r.route_relative_path
      r.on_root { r.respond(File.join('ROOT', r.route_relative_path)) }
      r.on('foo') { r.respond(File.join('FOO', r.route_relative_path)) }
      r.on('bar') { 
        r.on('baz') { r.respond(File.join('BAR/BAZ', r.route_relative_path)) }
        r.default { r.respond(File.join('BAR', r.route_relative_path)) }
      }
    end

    r = Qeweney.mock(':path' => '/')
    app.(r)
    assert_equal '/', default_relative_path
    assert_equal [[:respond, 'ROOT/', {}]], r.response_calls


    r = Qeweney.mock(':path' => '/foo/bar/baz')
    app.(r)
    assert_equal 'foo/bar/baz', default_relative_path
    assert_equal [[:respond, 'FOO/bar/baz', {}]], r.response_calls

    r = Qeweney.mock(':path' => '/bar/a/b/c')
    app.(r)
    assert_equal 'bar/a/b/c', default_relative_path
    assert_equal [[:respond, 'BAR/a/b/c', {}]], r.response_calls

    r = Qeweney.mock(':path' => '/bar/baz/b/c')
    app.(r)
    assert_equal 'bar/baz/b/c', default_relative_path
    assert_equal [[:respond, 'BAR/BAZ/b/c', {}]], r.response_calls
  end
end
