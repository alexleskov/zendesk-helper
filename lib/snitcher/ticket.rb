# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Ticket < Zendesk::Snitcher
      def do_action(ticket, thread, options)
        actions_by(ticket, thread, options) unless ticket.reply_count_equal?(thread.reply_count)
      end

      private

      def actions_by(ticket, thread, options)
        return if thread.last_reply_by_bot?

        case ticket.status
        when "closed"
          text = Zendesk::Text.ticket_closed(ticket.id)
          slack.chat_post_message(text: text, channel_id: channel_id, thread_ts: ticket.thread_ts.to_s).push if text
        else
          on_update_params = { id: ticket.id, custom_fields: [{ "id" => zd_reply_count_field_id, "value" => thread.reply_count }],
                               public_mode: false, status: options[:to] }
          comments = thread.reply_count_to_comments(:last, thread.reply_count.to_i - ticket.reply_count.to_i)
          on_update_params[:comment] = comments unless comments.empty?
          zendesk.ticket(on_update_params).update
        end
      end
    end
  end
end
