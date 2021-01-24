# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Pattern
      attr_reader :tickets, :threads

      def initialize
        @tickets = Zendesk::Snitcher::Ticket.new
        @threads = Zendesk::Snitcher::Thread.new
      end
    end
  end
end
