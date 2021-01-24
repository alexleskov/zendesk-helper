# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Pattern
      class Default < Zendesk::Snitcher::Pattern
        def run
          Zendesk::Request::Ticket::STATUSES.keys.each do |status|
            tickets.update(by: status.to_s, to: "open")
            threads.update(by: status.to_s)
          end
        end
      end
    end
  end
end