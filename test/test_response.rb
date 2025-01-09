# frozen_string_literal: true

require_relative 'helper'

class RedirectTest < Minitest::Test
  def test_redirect
    r = Qeweney::MockAdapter.mock
    r.redirect('/foo')

    assert_equal [
      [:respond, r, nil, {":status"=>302, "Location"=>"/foo"}]
    ], r.adapter.calls
  end

  def test_redirect_wirth_status
    r = Qeweney::MockAdapter.mock
    r.redirect('/bar', Qeweney::Status::MOVED_PERMANENTLY)

    assert_equal [
      [:respond, r, nil, {":status"=>301, "Location"=>"/bar"}]
    ], r.adapter.calls
  end
end

class StaticFileResponeTest < Minitest::Test
  def setup
    @path = File.join(__dir__, 'helper.rb')
    @stat = File.stat(@path)

    @etag = Qeweney::StaticFileCaching.file_stat_to_etag(@stat)
    @last_modified = Qeweney::StaticFileCaching.file_stat_to_last_modified(@stat)
    @content = IO.read(@path)
  end

  def test_serve_file
    r = Qeweney::MockAdapter.mock
    r.serve_file('helper.rb', base_path: __dir__)

    assert_equal [
      [:respond, r, @content, { 'etag' => @etag, 'last-modified' => @last_modified }]
    ], r.adapter.calls
  end

  def test_serve_file_with_cache_headers
    r = Qeweney::MockAdapter.mock('if-none-match' => @etag)
    r.serve_file('helper.rb', base_path: __dir__)
    assert_equal [
      [:respond, r, nil, { 'etag' => @etag, ':status' => Qeweney::Status::NOT_MODIFIED }]
    ], r.adapter.calls

    r = Qeweney::MockAdapter.mock('if-modified-since' => @last_modified)
    r.serve_file('helper.rb', base_path: __dir__)
    assert_equal [
      [:respond, r, nil, { 'etag' => @etag, ':status' => Qeweney::Status::NOT_MODIFIED }]
    ], r.adapter.calls

    r = Qeweney::MockAdapter.mock('if-none-match' => 'foobar')
    r.serve_file('helper.rb', base_path: __dir__)
    assert_equal [
      [:respond, r, @content, { 'etag' => @etag, 'last-modified' => @last_modified }]
    ], r.adapter.calls

    r = Qeweney::MockAdapter.mock('if-modified-since' => Time.now.httpdate)
    r.serve_file('helper.rb', base_path: __dir__)
    assert_equal [
      [:respond, r, @content, { 'etag' => @etag, 'last-modified' => @last_modified }]
    ], r.adapter.calls
  end

  def test_serve_file_deflate
    r = Qeweney::MockAdapter.mock('accept-encoding' => 'deflate')
    r.serve_file('helper.rb', base_path: __dir__)

    deflate = Zlib::Deflate.new
    deflated_content = deflate.deflate(@content, Zlib::FINISH)

    assert_equal [
      [:respond, r, deflated_content, {
        'etag' => @etag,
        'last-modified' => @last_modified,
        'vary' => 'Accept-Encoding',
        'content-encoding' => 'deflate'
      }]
    ], r.adapter.calls
  end

  def test_serve_file_gzip
    r = Qeweney::MockAdapter.mock('accept-encoding' => 'gzip')
    r.serve_file('helper.rb', base_path: __dir__)

    buf = StringIO.new
    z = Zlib::GzipWriter.new(buf)
    z << @content
    z.flush
    z.close
    gzipped_content = buf.string

    assert_equal [
      [:respond, r, gzipped_content, {
        'etag' => @etag,
        'last-modified' => @last_modified,
        'vary' => 'Accept-Encoding',
        'content-encoding' => 'gzip'
      }]
    ], r.adapter.calls
  end

  def test_serve_file_non_existent
    r = Qeweney::MockAdapter.mock
    r.serve_file('foo.rb', base_path: __dir__)
    assert_equal [
      [:respond, r, nil, { ':status' => Qeweney::Status::NOT_FOUND }]
    ], r.adapter.calls
  end
end

class UpgradeTest < Minitest::Test
  def test_upgrade
    r = Qeweney::MockAdapter.mock
    r.upgrade('df')

    assert_equal [
      [:respond, r, nil, {
        ':status' => 101,
        'Upgrade' => 'df',
        'Connection' => 'upgrade'
      }]
    ], r.adapter.calls


    r = Qeweney::MockAdapter.mock
    r.upgrade('df', { 'foo' => 'bar' })

    assert_equal [
      [:respond, r, nil, {
        ':status' => 101,
        'Upgrade' => 'df',
        'Connection' => 'upgrade',
        'foo' => 'bar'
      }]
    ], r.adapter.calls
  end

  def test_websocket_upgrade
    r = Qeweney::MockAdapter.mock(
      'connection' => 'upgrade',
      'upgrade' => 'websocket',
      'sec-websocket-version' => '23',
      'sec-websocket-key' => 'abcdefghij'
    )

    assert_equal 'websocket', r.upgrade_protocol

    r.upgrade_to_websocket('foo' => 'baz')
    accept = Digest::SHA1.base64digest('abcdefghij258EAFA5-E914-47DA-95CA-C5AB0DC85B11')

    assert_equal [
      [:respond, r, nil, {
        ':status' => 101,
        'Upgrade' => 'websocket',
        'Connection' => 'upgrade',
        'foo' => 'baz',
        'Sec-WebSocket-Accept' => accept
      }],
      [:websocket_connection, r]
    ], r.adapter.calls
  end
end

class ServeRackTest < Minitest::Test
  def test_serve_rack
    r = Qeweney::MockAdapter.mock(
      ':method' => 'get',
      ':path' => '/foo/bar?a=1&b=2%2F3',
      'accept' => 'blah'
    )
    r.serve_rack(->(env) {
      [404, {'Foo' => 'Bar'}, ["#{env['REQUEST_METHOD']} #{env['PATH_INFO']}"]]
    })

    assert_equal [
      [:respond, r, 'GET /foo/bar', {':status' => 404, 'Foo' => 'Bar' }]
    ], r.adapter.calls
  end
end
