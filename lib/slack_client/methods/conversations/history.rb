# frozen_string_literal: true

module Slack
  class Request
    class Conversations
      class History < Slack::Request::Conversations
        METHOD = ".history"

        def request_url
          "#{super}#{METHOD}"
        end
      end
    end
  end
end