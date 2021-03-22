# frozen_string_literal: true

module Qeweney
  def self.route(&block)
    ->(r) { r.route(&block) }
  end

  module RoutingMethods
    def route(&block)
      (@path_parts ||= path.split('/'))[@path_parts_idx ||= 1]
      res = catch(:stop) { yield self }
      return if res == :found
  
      respond(nil, ':status' => 404)
    end

    def route_found(&block)
      catch(:stop, &block)
      throw :stop, :found
    end

    @@regexp_cache = {}

    def route_part
      @path_parts[@path_parts_idx]
    end

    def route_relative_path
      @path_parts.empty? ? '/' : "/#{@path_parts[@path_parts_idx..-1].join('/')}"
    end

    def enter_route
      @path_parts_idx += 1
    end

    def leave_route
      @path_parts_idx -= 1
    end

    def on(route = nil, &block)
      if route
        return unless @path_parts[@path_parts_idx] == route
      end
  
      enter_route
      route_found(&block)
      leave_route
    end

    def is(route = '/', &block)
      return unless @path_parts[@path_parts_idx] == route && @path_parts_idx >= @path_parts.size

      route_found(&block)
    end

    def on_root(&block)
      return unless @path_parts_idx > @path_parts.size - 1

      route_found(&block)
    end

    def on_host(route, &block)
      return unless host == route

      route_found(&block)
    end

    def on_plain_http(route, &block)
      return unless scheme == 'http'

      route_found(&block)
    end
  
    def on_get(route = nil, &block)
      return unless method == 'get'
  
      on(route, &block)
    end
  
    def on_post(route = nil, &block)
      return unless method == 'post'
  
      on(route, &block)
    end

    def on_options(route = nil, &block)
      return unless method == 'options'
  
      on(route, &block)
    end

    def on_upgrade(protocol, &block)
      return unless upgrade_protocol == protocol

      route_found(&block)
    end

    def on_query_param(key)
      value = query[key]
      return unless value

      route_found { yield value }
    end

    def on_accept(accept, &block)
      if accept.is_a?(Regexp)
        return unless headers['accept'] =~ accept
      else
        return unless headers['accept'] == accept
      end

      route_found(&block)
    end

    def on_upgrade(protocol, &block)
      return unless upgrade_protocol == protocol

      route_found(&block)
    end

    def on_websocket_upgrade(&block)
      on_upgrade('websocket', &block)
    end

    def stop_routing
      throw :stop, :found
    end

    def default
      yield
      throw :stop, :found
    end
  end
end