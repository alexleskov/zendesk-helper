# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Pattern
      class Default < Zendesk::Snitcher::Pattern
        def run
          result = {}
          Zendesk::Request::Ticket::STATUSES.keys.each do |status|
            to_status = status == "new" ? "new" : "open"
            result[:tickets] = tickets.update(by: status.to_s, to: to_status)
            result[:threads] = threads.update(by: status.to_s)
          end
          result
        end
      end
    end
  end
end
