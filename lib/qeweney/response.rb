# frozen_string_literal: true

require_relative 'status'

module Qeweney
  module ResponseMethods
    def redirect(url, status = Status::FOUND)
      respond(nil, ':status' => status, 'Location' => url)
    end

    def serve_file(path, opts)
      File.open(file_full_path(path, opts), 'r') do |f|
        serve_io(f, opts)
      end
    rescue Errno::ENOENT
      respond(nil, ':status' => Status::NOT_FOUND)
    end

    def file_full_path(path, opts)
      if (base_path = opts[:base_path])
        File.join(opts[:base_path], path)
      else
        path
      end
    end

    def serve_io(io, opts)
      respond(io.read)
    end
  end
end