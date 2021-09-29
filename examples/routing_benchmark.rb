# frozen_string_literal: true

require 'bundler/setup'
require 'qeweney'
require 'benchmark/ips'

module Qeweney
  class MockAdapter
    attr_reader :calls

    def initialize
      @calls = []
    end

    def method_missing(sym, *args)
      calls << [sym, *args]
    end
  end

  def self.mock(headers = {})
    Request.new(headers, MockAdapter.new)
  end

  class Request
    def response_calls
      adapter.calls
    end
  end
end

def create_mock_request
  Qeweney.mock(':path' => '/hello/world', ':method' => 'post')
end

CTApp = ->(r) do
  r.route do
    r.on_root { r.redirect '/hello' }
    r.on('hello') do
      r.on_get('world') { r.respond 'Hello world' }
      r.on_get { r.respond 'Hello' }
      r.on_post do
        # puts 'Someone said Hello'
        r.redirect '/'
      end
    end
  end
end

FlowControlApp = ->(r) do
  if r.path == '/'
    return r.redirect '/hello'
  elsif r.current_path_part == 'hello'
    r.enter_route
    if r.method == 'get' && r.current_path_part == 'world'
      return r.respond('Hello world')
    elsif r.method == 'get'
      return r.respond('Hello')
    elsif r.method == 'post'
      return r.redirect('/')
    end
    r.leave_route
  end
  r.respond(nil, ':status' => 404)
end

class Qeweney::Request
  def get?
    method == 'get'
  end

  def post?
    method == 'post'
  end
end

NicerFlowControlApp = ->(r) do
  case r.current_path_part
  when '/'
    return r.redirect('/hello')
  when 'hello'
    r.enter_route
    if r.get? && r.current_route == 'world'
      return r.respond('Hello world')
    elsif r.get?
      return r.respond('Hello')
    elsif r.post?
      return r.redirect('/')
    end
    r.leave_route
  end
  r.respond(nil, ':status' => 404)
end

OptimizedRubyApp = ->(r) do
  path = r.path
  if path == '/'
    return r.redirect('/hello')
  elsif path =~ /^\/hello(.+)/
    method = r.method
    if method == 'get'
      rest = Regexp.last_match(1)
      if rest == '/world'
        return r.respond('Hello world')
      else
        return r.respond('Hello')
      end
    elsif method == 'post'
      # puts 'Someone said Hello'
      return r.redirect('/')
    end
  end
  r.respond(nil, ':status' => 404)
end

def test
  r = create_mock_request
  puts '* catch/throw'
  CTApp.call(r)
  p r.response_calls

  r = create_mock_request
  puts '* classic flow control'
  FlowControlApp.call(r)
  p r.response_calls

  r = create_mock_request
  puts '* nicer flow control'
  NicerFlowControlApp.call(r)
  p r.response_calls

  r = create_mock_request
  puts '* optimized Ruby'
  OptimizedRubyApp.call(r)
  p r.response_calls
end

def benchmark
  Benchmark.ips do |x|
    x.config(:time => 3, :warmup => 1)

    x.report("catch/throw") { CTApp.call(create_mock_request) }
    x.report("flow control") { FlowControlApp.call(create_mock_request) }
    x.report("nicer flow control") { NicerFlowControlApp.call(create_mock_request) }
    x.report("hand-optimized") { OptimizedRubyApp.call(create_mock_request) }

    x.compare!
  end
end

test
benchmark