# frozen_string_literal: true

require_relative './request_info'
require_relative './routing'
require_relative './response'

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

    def next_chunk
      if @buffered_body_chunks
        chunk = @buffered_body_chunks.shift
        @buffered_body_chunks = nil if @buffered_body_chunks.empty?
        return chunk
      end

      @message_complete ? nil : @adapter.get_body_chunk
    end
    
    def each_chunk
      if @buffered_body_chunks
        while (chunk = @buffered_body_chunks.shift)
          yield chunk
        end
        @buffered_body_chunks = nil
      end
      while !@message_complete && (chunk = @adapter.get_body_chunk)
        yield chunk
      end
    end

    def complete!(keep_alive = nil)
      @message_complete = true
      @keep_alive = keep_alive
    end
    
    def complete?
      @message_complete
    end
    
    def consume
      @adapter.consume_request
    end
    
    def keep_alive?
      @keep_alive
    end
    
    def read
      buf = @buffered_body_chunks ? @buffered_body_chunks.join : nil
      while (chunk = @adapter.get_body_chunk)
        (buf ||= +'') << chunk
      end
      @buffered_body_chunks = nil
      buf
    end
    alias_method :body, :read
    
    def respond(body, headers = {})
      @adapter.respond(body, headers)
      @headers_sent = true
    end
    
    def send_headers(headers = {}, empty_response = false)
      return if @headers_sent
      
      @headers_sent = true
      @adapter.send_headers(headers, empty_response: empty_response)
    end
    
    def send_chunk(body, done: false)
      send_headers({}) unless @headers_sent
      
      @adapter.send_chunk(body, done: done)
    end
    alias_method :<<, :send_chunk
    
    def finish
      send_headers({}) unless @headers_sent
      
      @adapter.finish
    end

    def headers_sent?
      @headers_sent
    end
  end
end