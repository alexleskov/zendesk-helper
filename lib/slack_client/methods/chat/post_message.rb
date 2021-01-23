# frozen_string_literal: true

module Slack
  class Request
    class Chat
      class PostMessage < Slack::Request::Chat
        METHOD = ".postMessage"

        def request_url
          "#{super}#{METHOD}"
        end
      end
    end
  end
end