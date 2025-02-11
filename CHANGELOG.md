## 0.20 2025-01-09

- Improve `Qeweney::MockAdapter`

## 0.18 2022-02-16

- Implement `Request#rewrite!` (#2)

## 0.17 2022-02-10

- Fix default return value in `TestAdapter#status`

## 0.16 2022-01-22

- Use frozen empty hash as default headers in response methods
- Add `text` key in registered MIME types

## 0.15 2022-01-08

- Add `TestAdapter` class for testing requests and responses
- Add `RoutingMethods#reject` method

## 0.14 2021-08-10

- Fix Request#on with paths containing slashes

## 0.13.1 2021-08-03

- Fix `Request#read`

## 0.13 2021-08-02

- Restore `Request#complete?` method
- Add buffered_only argument to `Request#next_chunk`

## 0.12 2021-07-30

- Remove `Request#consume` method
- Remove `Request#complete?` and associated methods

## 0.11 2021-07-26

- Fix rack env (digital-fabric/tipi#11)

## 0.10 2021-06-24

- Include file stat in `#serve_io` options as hint for adapter
- Fix `MimeTypes#[]` for empty extension

## 0.9.1 2021-06-14

- Fix reading host from `:authority` header

## 0.9.0 2021-05-14

- Fix query parsing for fields with empty value

## 0.8.4 2021-03-23

- Rename and fix `#parse_query` to deal with no-value query parts

## 0.8.3 2021-03-22

- Streamline routing behaviour in sub routes (an explicit default sub route is
  now required if no sub route matches)

## 0.8.2 2021-03-17

- Fix form parsing when charset is specified

## 0.8.1 2021-03-10

- Add `Request#transfer_counts`, `Request#total_transfer`
- Fix `Request#rx_incr`

## 0.8 2021-03-10

- Pass request as first argument to all adapter methods

## 0.7.5 2021-03-08

- Set content-type header in `#serve_file`

## 0.7.4 2021-03-07

- Add `Request#cookies`
- Add `Request#full_uri`

## 0.7.3 2021-03-05

- Fix `parse_urlencoded_form_data`

## 0.7.2 2021-03-04

- Add `#route_relative_path` method

## 0.6 2021-03-03

- More work on routing (still WIP)
- Implement two-way Rack adapters

## 0.5 2021-02-15

- Implement upgrade and WebSocket upgrade responses

## 0.4 2021-02-12

- Implement caching and compression for serving static files

## 0.3 2021-02-12

- Implement `Request#serve_io`, `Request#serve_file`, `Request#redirect`
- Add basic MIME types
- Add HTTP status codes

## 0.2 2021-02-11

- Gem renamed to Qeweney

## 0.1 2021-02-11

- Code extracted from Tipi