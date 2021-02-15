## Serve files / arbitrary content

- `#serve_file(path, opts)`
  - See here: https://golang.org/pkg/net/http/#ServeFile
  - support for `Range` header

- `#serve_content(io, opts)`
  - See here: https://golang.org/pkg/net/http/#ServeContent
  - support for `Range` header

## route on host

- `#on_host`:

  ```ruby
  req.route do
    req.on_host 'example.com' do
      req.redirect "https://www.example.com#{req.uri}"
    end
  end
  ```

- `#on_http`:

  ```ruby
  req.route do
    req.on_http do
      req.redirect "https://#{req.host}#{req.uri}"
    end
  end
  ```

- shorthand:

  ```ruby
  req.route do
    req.on_http { req.redirect_to_https }
    req.on_host 'example.com' do
      req.redirect_to_host('www.example.com')
    end
  end
  ```

## templates

- needs to be pluggable - allow any kind of template

```ruby
WEBSITE_PATH = File.join(__dir__, 'docs')
STATIC_PATH = File.join(WEBSITE_PATH, 'static')
LAYOUTS_PATH = File.join(WEBSITE_PATH, '_layouts')

PAGES = Tipi::PageManager(
  base_path: WEBSITE_PATH,
  engine: :markdown,
  layouts: LAYOUTS_PATH
)

app = Tipi.app do |r|
  r.on 'static' do
    r.serve_file(r.routing_path, base_path: ASSETS_PATH)
  end

  r.default do
    PAGES.serve(r)
  end
end
```

## Rewriting URLs

```ruby
app = Tipi.app do |r|
  r.rewrite '/' => '/docs/index.html'
  r.rewrite '/docs' => '/docs/'
  r.rewrite '/docs/' => '/docs/index.html'

  # or maybe
  r.on '/docs/'
end
```