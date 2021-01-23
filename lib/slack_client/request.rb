# frozen_string_literal: true

module Slack
  class Request < Request
    def request_url
      "#{Slack::Client::HOST}api/#{SOURCE}"
    end

    private

    def set_default_headers
      super
      @headers["Authorization"] = "#{$app_config.call(:slack_token_auth_type)} #{client.access_token.value if client}"
    end
  end
end