# frozen_string_literal: true

module Slack
  class Request
    class Conversations
      class Replies < Slack::Request::Conversations
        METHOD = ".replies"

        def request_url
          "#{super}#{METHOD}"
        end  
      end
    end
  end
end