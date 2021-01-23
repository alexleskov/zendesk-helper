# frozen_string_literal: true

module Zendesk
  class Request < Request
    def request_url
      "#{Zendesk::Client::HOST}api/v2/#{SOURCE}"
    end

    private

    def set_default_headers
      super
      @headers["Authorization"] = "#{$app_config.call(:zd_token_auth_type)} #{client.access_token.create.value if client}"
    end
  end
end
