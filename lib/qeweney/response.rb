# frozen_string_literal: true

module Qeweney
  module ResponseMethods
    def redirect(url)
      respond(nil, ':status' => 302, 'Location' => url)
    end
  end
end