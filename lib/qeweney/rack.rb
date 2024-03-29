# frozen_string_literal: true

module Qeweney
  class RackRequestAdapter
    def initialize(env)
      @env = env
      @response_headers = {}
      @response_body = []
    end

    def request_headers
      request_http_headers.merge(
        ':scheme' => @env['rack.url_scheme'],
        ':method' => @env['REQUEST_METHOD'].downcase,
        ':path' => request_path_from_env
      )
    end

    def request_path_from_env
      path = File.join(@env['SCRIPT_NAME'], @env['PATH_INFO'])
      path = path + "?#{@env['QUERY_STRING']}" if @env['QUERY_STRING']
      path
    end

    def request_http_headers
      headers = {}
      @env.each do |k, v|
        next unless k =~ /^HTTP_(.+)$/

        headers[Regexp.last_match(1).downcase.gsub('_', '-')] = v
      end
      headers
    end

    def respond(req, body, headers)
      @response_body << body
      @response_headers = headers
    end

    def send_headers(req, headers, empty_response: nil)
      @response_headers = headers
    end

    def send_chunk(req, body, done: false)
      @response_body << body
    end

    def finish(req)
    end

    def rack_response
      @status = @response_headers.delete(':status')
      [
        @status,
        @response_headers,
        @response_body
      ]
    end
  end

  def self.rack(&block)
    proc do |env|
      adapter = RackRequestAdapter.new(env)
      req = Request.new(adapter.request_headers, adapter)
      block.(req)
      adapter.rack_response
    end
  end

  # TODO: integrate in env
  # Implements a rack input stream:
  # https://www.rubydoc.info/github/rack/rack/master/file/SPEC#label-The+Input+Stream
  class InputStream
    def initialize(request)
      @request = request
    end

    def gets; end

    def read(length = nil, outbuf = nil); end

    def each(&block)
      @request.each_chunk(&block)
    end

    def rewind; end
  end

  def self.rack_env_from_request(request)
    Hash.new do |h, k|
      h[k] = rack_env_value_from_request(request, k)
    end
  end

  # TODO: improve conformance to rack spec
  # TODO: set values like port, scheme etc from actual connection
  RACK_ENV = {
    'SCRIPT_NAME'                    => '',
    'rack.version'                   => [1, 3],
    'SERVER_PORT'                    => '80', # ?
    'rack.url_scheme'                => 'http', # ?
    'rack.errors'                    => STDERR, # ?
    'rack.multithread'               => false,
    'rack.run_once'                  => false,
    'rack.hijack?'                   => false,
    'rack.hijack'                    => nil,
    'rack.hijack_io'                 => nil,
    'rack.session'                   => nil,
    'rack.logger'                    => nil,
    'rack.multipart.buffer_size'     => nil,
    'rack.multipar.tempfile_factory' => nil
  }

  HTTP_HEADER_RE = /^HTTP_(.+)$/.freeze

  def self.rack_env_value_from_request(request, key)
    case key
    when 'REQUEST_METHOD' then request.method.upcase
    when 'PATH_INFO'      then request.path
    when 'QUERY_STRING'   then request.query_string || ''
    when 'SERVER_NAME'    then request.headers['host']
    when 'rack.input'     then InputStream.new(request)
    when HTTP_HEADER_RE   then request.headers[$1.gsub('_', '-').downcase]
    else                       RACK_ENV[key]
    end
  end
end
