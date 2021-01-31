# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Pattern
      class Default < Zendesk::Snitcher::Pattern
        def go
          Zendesk::Ticket::STATUSES.keys.each do |status|
            to_status = status == "new" ? "new" : "open"
            tickets.update(by: status.to_s, to: to_status)
            threads.update(by: status.to_s)
          end
        end
      end
    end
  end
end
