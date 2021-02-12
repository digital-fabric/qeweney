# frozen_string_literal: true

module Qeweney
  # File extension to MIME type mapping
  module MimeTypes
    TYPES = {
      'html'  => 'text/html',
      'css'   => 'text/css',
      'js'    => 'application/javascript',
      'txt'   => 'text/plain'

      'gif'   => 'image/gif',
      'jpg'   => 'image/jpeg',
      'jpeg'  => 'image/jpeg',
      'png'   => 'image/png',
      'ico'   => 'image/x-icon',

      'pdf'   => 'application/pdf',
      'json'  => 'application/json',
    }.freeze

    def [](ref)
      case ref
      when Symbol
        TYPES[ref.to_s]
      when /\.?([^\.]+)$/
        TYPES[Regexp.last_match(1)]
      else
        raise "Invalid argument #{ref.inspect}"
      end
    end
  end
end