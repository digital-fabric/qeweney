# frozen_string_literal: true

module Qeweney
  module RoutingMethods
    def route(&block)
      res = catch(:stop) { yield self }
      return if res == :found
  
      respond(nil, ':status' => 404)
    end

    def route_found(&block)
      catch(:stop, &block)
      throw :stop, :found
    end

    @@regexp_cache = {}

    def routing_path
      @__routing_path__
    end
  
    def on(route = nil, &block)
      @__routing_path__ ||= path

      if route
        regexp = (@@regexp_cache[route] ||= /^\/#{route}(\/.*)?/)
        return unless @__routing_path__ =~ regexp

        @__routing_path__ = Regexp.last_match(1) || '/'
      end
  
      route_found(&block)
    end

    def is(route = '/', &block)
      return unless @__routing_path__ == route

      route_found(&block)
    end

    def on_root(&block)
      return unless @__routing_path__ == '/'

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

    def stop_routing
      yield if block_given?
      throw :stop, :found
    end
  end
end