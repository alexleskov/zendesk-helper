# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Pattern
      attr_reader :tickets, :threads
      
      def initialize
        @tickets = Zendesk::Snithcer::Ticket.new
        @threads = Zendesk::Snithcer::Thread.new
      end
    end
  end
end