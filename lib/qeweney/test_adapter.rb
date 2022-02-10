# frozen_string_literal: true

module Qeweney
  class TestAdapter
    attr_reader :body, :headers

    def get_body_chunk
      nil
    end

    def respond(req, body, headers)
      @body = body
      @headers = headers
    end

    def status
      headers[':status'] || Qeweney::Status::OK
    end

    def self.mock(headers = {})
      headers[':method'] ||= ''
      headers[':path'] ||= ''
      Request.new(headers, new)
    end
  end
end
