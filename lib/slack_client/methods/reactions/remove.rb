# frozen_string_literal: true

module Slack
  class Request
    class Reactions
      class Remove < Slack::Request::Reactions
        METHOD = ".remove"

        def request_url
          "#{super}#{METHOD}"
        end
      end
    end
  end
end
