# frozen_string_literal: true

require 'uri'
require 'escape_utils'

module Qeweney
  module RequestInfoMethods
    def host
      @headers['host']
    end

    def connection
      @headers['connection']
    end

    def upgrade_protocol
      connection == 'upgrade' && @headers['upgrade']&.downcase
    end

    def websocket_version
      headers['sec-websocket-version'].to_i
    end

    def protocol
      @protocol ||= @adapter.protocol
    end
    
    def method
      @method ||= @headers[':method'].downcase
    end
    
    def scheme
      @scheme ||= @headers[':scheme']
    end
    
    def uri
      @uri ||= URI.parse(@headers[':path'] || '')
    end
    
    def full_uri
      @full_uri = "#{scheme}://#{host}#{uri}"
    end
    
    def path
      @path ||= uri.path
    end
    
    def query_string
      @query_string ||= uri.query
    end
    
    def query
      return @query if @query
      
      @query = (q = uri.query) ? parse_query(q) : {}
    end
    
    QUERY_KV_REGEXP = /([^=]+)(?:=(.*))?/
    
    def parse_query(query)
      query.split('&').each_with_object({}) do |kv, h|
        k, v = kv.match(QUERY_KV_REGEXP)[1..2]
        # k, v = kv.split('=')
        h[k.to_sym] = v ? URI.decode_www_form_component(v) : true
      end
    end

    def request_id
      @headers['x-request-id']
    end

    def forwarded_for
      @headers['x-forwarded-for']
    end

    # TODO: should return encodings in client's order of preference (and take
    # into account q weights)
    def accept_encoding
      encoding = @headers['accept-encoding']
      return [] unless encoding

      encoding.split(',').map { |i| i.strip }
    end

    def cookies
      @cookies ||= parse_cookies(headers['cookie'])
    end

    COOKIE_RE = /^([^=]+)=(.*)$/.freeze
    SEMICOLON = ';'
  
    def parse_cookies(cookies)
      return {} unless cookies

      cookies.split(SEMICOLON).each_with_object({}) do |c, h|
        raise BadRequestError, 'Invalid cookie format' unless c.strip =~ COOKIE_RE
  
        key, value = Regexp.last_match[1..2]
        h[key] = EscapeUtils.unescape_uri(value)
      end
    end
  end

  module RequestInfoClassMethods
    def parse_form_data(body, headers)
      case (content_type = headers['content-type'])
      when /^multipart\/form\-data; boundary=([^\s]+)/
        boundary = "--#{Regexp.last_match(1)}"
        parse_multipart_form_data(body, boundary)
      when /^application\/x-www-form-urlencoded/
        parse_urlencoded_form_data(body)
      else
        raise "Unsupported form data content type: #{content_type}"
      end
    end

    def parse_multipart_form_data(body, boundary)
      parts = body.split(boundary)
      parts.each_with_object({}) do |p, h|
        next if p.empty? || p == "--\r\n"

        # remove post-boundary \r\n
        p.slice!(0, 2)
        parse_multipart_form_data_part(p, h)
      end
    end

    def parse_multipart_form_data_part(part, hash)
      body, headers = parse_multipart_form_data_part_headers(part)
      disposition = headers['content-disposition'] || ''

      name = (disposition =~ /name="([^"]+)"/) ? Regexp.last_match(1) : nil
      filename = (disposition =~ /filename="([^"]+)"/) ? Regexp.last_match(1) : nil

      if filename
        hash[name] = { filename: filename, content_type: headers['content-type'], data: body }
      else
        hash[name] = body
      end
    end

    def parse_multipart_form_data_part_headers(part)
      headers = {}
      while true
        idx = part.index("\r\n")
        break unless idx

        header = part[0, idx]
        part.slice!(0, idx + 2)
        break if header.empty?

        next unless header =~ /^([^\:]+)\:\s?(.+)$/
        
        headers[Regexp.last_match(1).downcase] = Regexp.last_match(2)
      end
      # remove trailing \r\n
      part.slice!(part.size - 2, 2)
      [part, headers]
    end

    PARAMETER_RE = /^(.+)=(.*)$/.freeze
    MAX_PARAMETER_NAME_SIZE = 256
    MAX_PARAMETER_VALUE_SIZE = 2**20 # 1MB

    def parse_urlencoded_form_data(body)
      body.force_encoding(Encoding::UTF_8) unless body.encoding == Encoding::UTF_8
      body.split('&').each_with_object({}) do |i, m|
        raise 'Invalid parameter format' unless i =~ PARAMETER_RE
  
        k = Regexp.last_match(1)
        raise 'Invalid parameter size' if k.size > MAX_PARAMETER_NAME_SIZE
  
        v = Regexp.last_match(2)
        raise 'Invalid parameter size' if v.size > MAX_PARAMETER_VALUE_SIZE
  
        m[EscapeUtils.unescape_uri(k)] = EscapeUtils.unescape_uri(v)
      end
    end
  end
end