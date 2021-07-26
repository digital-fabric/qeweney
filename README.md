# Qeweney - add water, makes its own sauce!

[![Gem Version](https://badge.fury.io/rb/qeweney.svg)](http://rubygems.org/gems/qeweney)
[![Modulation Test](https://github.com/digital-fabric/qeweney/workflows/Tests/badge.svg)](https://github.com/digital-fabric/qeweney/actions?query=workflow%3ATests)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/digital-fabric/qeweney/blob/master/LICENSE)

## Cross-library HTTP request / response API for servers

Qeweney provides a uniform API for dealing with HTTP requests and responses on
the server side. Qeweney defines a uniform adapter interface that allows
handling incoming HTTP requests and sending HTTP responses over any protocol or
transport, be it HTTP/1, HTTP/2 or a Rack interface.

Qeweney is primarily designed to work with
[Tipi](https://github.com/digital-fabric/tipi), but can also be used directly
inside Rack apps, or to drive Rack apps.

## Features

- Works with different web server APIs, notably Tipi, Digital Fabric, and Rack.
- Transport-agnostic.
- High-performance routing API inspired by Roda.
- Rich API for extracting data from HTTP requests: form parsing, cookies, file
  uploads, etc.
- Rich API for constructing HTTP responses: streaming responses, HTTP upgrades,
  static file serving, delate and gzip encoding, caching etc.
- Suitable for both blocking and non-blocking concurrency models.
- Allows working with request before request body is read and parsed.

## Overview

In Qeweney, the main class developers will interact with is `Qeweney::Request`,
which encapsulates an HTTP request (from the server's point of view), and offers
an API for extracting request information and responding to that request.

A request is always associated with an _adapter_, an object that implements the
Qeweney adapter interface, and that allows reading request bodies (for uploads
and form submissions) and sending responses.

## The Qeweney Adapter Interface

```ruby
class AdapterInterface
  # Reads a chunk from the request body
  # @req [Qeweney::Request] request for which the chunk is to be read
  def get_body_chunk(req)
  end

  # Send a non-streaming response
  # @req [Qeweney::Request] request for which the response is sent
  # @body [String, nil] response body
  # @headers [Hash] response headers
  def respond(req, body, headers)
  end

  # Send only headers
  # @req [Qeweney::Request] request for which the response is sent
  # @headers [Hash] response headers
  # @empty_response [boolean] whether response is empty
  def send_headers(req, headers, empty_response: nil)
  end

  # Send a body chunk (this implies chunked transfer encoding)
  # @req [Qeweney::Request] request for which the response is sent
  # @body [String, nil] chunk
  # @done [boolean] whether response is finished
  def send_chunk(req, body, done: false)
  end

  # Finishes response
  # @req [Qeweney::Request] request for which the response is sent
  def finish(req)
  end
end
```
