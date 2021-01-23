# frozen_string_literal: true

module Slack
  class Request
    class Reactions
        class Add < Slack::Request::Reactions
          METHOD = ".add"

          def request_url
            "#{super}#{METHOD}"
          end
      end
    end
  end
end