# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Pattern
      class Default < Zendesk::Snitcher::Pattern
        def go
          Zendesk::Ticket::STATUSES.keys.each do |status|
            p "Tickets update. Time: #{Time.now}. Status: #{status}"
            to_status = status.to_s == "new" ? "new" : "open"
            tickets.update(by: status.to_s, to: to_status) # TODO: Change replies limit and update comments sending to ticket
          end
          Zendesk::Ticket::STATUSES.keys.each do |status|
            p "Threads update. Time: #{Time.now}. Status: #{status}"
            threads.update(by: status.to_s, replies_limit: 1)
          end
        end
      end
    end
  end
end
