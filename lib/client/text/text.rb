# frozen_string_literal: true

module Zendesk
  class Text
    class << self
      def ticket_link(id)
        "<#{Zendesk::Client::HOST}agent/tickets/#{id}|#{I18n.t('ticket')} ##{id}>"
      end

      def ticket_closed(id)
        "#{ticket_link(id)} #{I18n.t('on_this_thread_already_closed')}. #{I18n.t('do_on_closed_ticket')}."
      end

      def ticket_on_status(status, id)
        text =
          case status
          when "hold"
            "*#{I18n.t('hold')}*. #{I18n.t('about_hold')}."
          when "pending", "solved"
            "*#{I18n.t('pending')}/#{I18n.t('solved')}*. #{I18n.t('about_pending')}."
          when "open"
            "*#{I18n.t('open')}*. #{I18n.t('about_open')}."
          when "closed"
            "*#{I18n.t('closed')}*. #{I18n.t('about_closed')}."
          end
        return unless text

        "#{ticket_link(id)} #{I18n.t('now_in_status')}: #{text}"
      end
    end
  end
end
