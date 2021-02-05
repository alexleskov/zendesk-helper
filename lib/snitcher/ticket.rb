# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Ticket < Zendesk::Snitcher
      def do_action(ticket, thread, options)
        actions_by(ticket, thread, options) unless ticket.reply_count_equal?(thread.reply_count)
      end

      private

      def actions_by(ticket, thread, options)
        case ticket.status
        when "closed"
          text = Zendesk::Text.ticket_closed(ticket.id)
          slack.chat_post_message(text: text, channel_id: channel_id, thread_ts: ticket.thread_ts.to_s).push if text && !thread.last_reply_by_bot?
        else
          unless thread.messages.empty?
            zendesk.ticket(id: ticket.id, comment: thread.to_comments(drop: ticket.reply_count), public_mode: false).update
          end
          unless thread.last_reply_by_bot?
            on_update_params = { id: ticket.id, custom_fields: [{ "id" => zd_reply_count_field_id, "value" => thread.reply_count }] }
            on_update_params[:status] = options[:to]
            zendesk.ticket(on_update_params).update
          end
        end
      end
    end
  end
end
