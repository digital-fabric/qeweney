# frozen_string_literal: true

require_relative 'helper'

class RoutingTest < Minitest::Test
  App1 = ->(r) do
    r.route do
      r.on_root { r.redirect '/hello' }
      r.on('hello') do
        r.on_get('world') { r.respond 'Hello world' }
        r.on_get { r.respond 'Hello' }
        r.on_post do
          r.redirect '/'
        end
        r.default { r.respond nil, ':status' => 404 }
      end
    end
  end

  def test_app1
    r = Qeweney::MockAdapter.mock(':path' => '/foo')
    App1.(r)
    assert_equal [[:respond, r, nil, { ':status' => 404 }]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/')
    App1.(r)
    assert_equal [[:respond, r, nil, { ':status' => 302, 'Location' => '/hello' }]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/hello', ':method' => 'foo')
    App1.(r)
    assert_equal [[:respond, r, nil, { ':status' => 404 }]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/hello', ':method' => 'get')
    App1.(r)
    assert_equal [[:respond, r, 'Hello', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/hello', ':method' => 'post')
    App1.(r)
    assert_equal [[:respond, r, nil, { ':status' => 302, 'Location' => '/' }]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/hello/world', ':method' => 'get')
    App1.(r)
    assert_equal [[:respond, r, 'Hello world', {}]], r.adapter.calls
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

    r = Qeweney::MockAdapter.mock(':path' => '/')
    app.(r)
    assert_equal [[:respond, r, 'root', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/foo')
    app.(r)
    assert_equal [[:respond, r, 'foo root', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/foo/bar')
    app.(r)
    assert_equal [[:respond, r, 'bar root', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/foo/bar/baz')
    app.(r)
    assert_equal [[:respond, r, 'baz root', {}]], r.adapter.calls
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
      r.on('baz') { r.respond(r.route_relative_path) }
    end

    r = Qeweney::MockAdapter.mock(':path' => '/')
    app.(r)
    assert_equal '/', default_relative_path
    assert_equal [[:respond, r, 'ROOT/', {}]], r.adapter.calls


    r = Qeweney::MockAdapter.mock(':path' => '/foo/bar/baz')
    app.(r)
    assert_equal '/foo/bar/baz', default_relative_path
    assert_equal [[:respond, r, 'FOO/bar/baz', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/bar/a/b/c')
    app.(r)
    assert_equal '/bar/a/b/c', default_relative_path
    assert_equal [[:respond, r, 'BAR/a/b/c', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/bar/baz/b/c')
    app.(r)
    assert_equal '/bar/baz/b/c', default_relative_path
    assert_equal [[:respond, r, 'BAR/BAZ/b/c', {}]], r.adapter.calls

    r = Qeweney::MockAdapter.mock(':path' => '/baz/d/e/f')
    app.(r)
    assert_equal '/baz/d/e/f', default_relative_path
    assert_equal [[:respond, r, '/d/e/f', {}]], r.adapter.calls
  end

  def test_well_known
    app = Qeweney.route do |r|
      r.on('.well-known/acme-challenge') { r.respond(r.route_relative_path) }
      r.default { r.respond('not found') }
    end

    r = Qeweney::MockAdapter.mock(':path' => '/.well-known/acme-challenge/foo')
    app.(r)
    assert_equal [[:respond, r, '/foo', {}]], r.adapter.calls
  end
end

