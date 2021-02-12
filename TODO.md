## Serve files / arbitrary content

- `#serve_file(path, opts)`
  - See here: https://golang.org/pkg/net/http/#ServeFile
  - support for `Range` header
  - support for caching (specified in opts)
  - support for serving from routing path:

    ```ruby
      req.route do
        req.on 'assets' do
          req.serve_file(req.routing_path, base_path: STATIC_PATH)
        end
      end

      # or convenience method
      req.route do
        req.on_static_route 'assets', base_path: STATIC_PATH
      end
    ```

- `#serve_content(io, opts)`
  - See here: https://golang.org/pkg/net/http/#ServeContent
  - support for `Range` header
  - support for caching (specified in opts)
  - usage:

    ```ruby
      req.route do
        req.on 'mypdf' do
          File.open('my.pdf', 'r') { |f| req.serve_content(io) }
        end
      end
    ```

## Caching

```ruby
req.route do
  req.on 'assets' do
    # setting cache to true implies the following:
    # - etag (calculated from file stat)
    # - last-modified (from file stat)
    # - vary: Accept-Encoding

    # before responding, looks at the following headers
    # if-modified-since: (date from client's cache)
    # if-none-match: (etag from client's cache)
    # cache-control: no-cache will prevent caching
    req.serve_file(path, base_path: STATIC_PATH, cache: true)

    # We can control this manually instead:
    req.serve_file(path, base_path: STATIC_PATH, cache: {
      etag: 'blahblah',
      last_modified: Time.now - 365*86400,
      vary: 'Accept-Encoding, User-Agent'
    })
  end
end
```

So, the algorithm:

```ruby
def validate_client_cache(path)
  return false if headers['cache-control'] == 'no-cache'
  
  stat = File.stat(path)
  etag = file_stat_to_etag(path, stat)
  return false if headers['if-none-match'] != etag

  modified = file_stat_to_modified_stamp(stat)
  return false if headers['if-modified-since'] != modified

  true
end

def file_stat_to_etag(path, stat)
  "#{stat.mtime.to_i.to_s(36)}#{stat.size.to_s(36)}"
end

require 'time'

def file_stat_to_modified_stamp(stat)
  stat.mtime.httpdate
end
```

## response compression

```ruby
req.route do
  req.on 'assets' do
    # gzip on the fly
    req.serve_file(path, base_path: STATIC_PATH, gzip: :gzip)
  end
end

```