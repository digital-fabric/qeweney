# frozen_string_literal: true

require_relative './request_info'
require_relative './routing'
require_relative './response'
require_relative './rack'

module Qeweney
  # HTTP request
  class Request
    include RequestInfoMethods
    include RoutingMethods
    include ResponseMethods

    extend RequestInfoClassMethods

    attr_reader :headers, :adapter
    attr_accessor :__next__
    
    def initialize(headers, adapter)
      @headers  = headers
      @adapter  = adapter
    end
        
    def buffer_body_chunk(chunk)
      @buffered_body_chunks ||= []
      @buffered_body_chunks << chunk
    end

    def next_chunk(buffered_only = false)
      if @buffered_body_chunks
        chunk = @buffered_body_chunks.shift
        @buffered_body_chunks = nil if @buffered_body_chunks.empty?
        return chunk
      elsif buffered_only
        return nil
      end

      @adapter.get_body_chunk(self, buffered_only)
    end
    
    def each_chunk
      if @buffered_body_chunks
        while (chunk = @buffered_body_chunks.shift)
          yield chunk
        end
        @buffered_body_chunks = nil
      end
      while (chunk = @adapter.get_body_chunk(self))
        yield chunk
      end
    end

    def read
      @adapter.get_body(self)
    end
    alias_method :body, :read
    
    def respond(body, headers = {})
      @adapter.respond(self, body, headers)
      @headers_sent = true
    end
    
    def send_headers(headers = {}, empty_response = false)
      return if @headers_sent
      
      @headers_sent = true
      @adapter.send_headers(self, headers, empty_response: empty_response)
    end
    
    def send_chunk(body, done: false)
      send_headers({}) unless @headers_sent
      
      @adapter.send_chunk(self, body, done: done)
    end
    alias_method :<<, :send_chunk
    
    def finish
      send_headers({}) unless @headers_sent
      
      @adapter.finish(self)
    end

    def headers_sent?
      @headers_sent
    end

    def rx_incr(count)
      headers[':rx'] ? headers[':rx'] += count : headers[':rx'] = count
    end

    def tx_incr(count)
      headers[':tx'] ? headers[':tx'] += count : headers[':tx'] = count
    end

    def transfer_counts
      [headers[':rx'], headers[':tx']]
    end

    def total_transfer
      (headers[':rx'] || 0) + (headers[':tx'] || 0)
    end
  end
end