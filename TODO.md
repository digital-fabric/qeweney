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
