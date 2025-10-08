# frozen_string_literal: true

require 'qeweney'

module Qeweney
  class MockAdapter
    attr_reader :response_body, :response_headers, :calls

    def get_body_chunk(_req, _buffered_only)
      @request_body_chunks.shift
    end

    def get_body(_req)
      body = @request_body_chunks.join('')
      @request_body_chunks.clear
      body
    end

    def complete?(_req)
      @request_body_chunks.empty?
    end

    def initialize(request_body)
      case request_body
      when Array
        @request_body_chunks = request_body
      when nil
        @request_body_chunks = []
      else
        @request_body_chunks = [request_body]
      end
      @calls = []
    end

    def set_response_headers(headers)
      @response_headers = header
    end

    def respond(req, body, headers)
      @calls << [:respond, req, body, headers]
      @response_body = body
      @response_headers = headers
    end

    def status
      response_headers[':status'] || Qeweney::Status::OK
    end

    def method_missing(sym, *args)
      calls << [sym, *args]
    end

    def self.mock(headers = {}, request_body = nil)
      headers[':method'] ||= ''
      headers[':path'] ||= ''
      Request.new(headers, new(request_body))
    end
  end
end
