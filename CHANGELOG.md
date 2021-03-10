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