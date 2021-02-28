# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Thread < Zendesk::Snitcher
      def do_action(ticket, thread, _options)
        actions_by(ticket, thread) unless thread.reaction_include?(ticket.reaction_by_status)
      end

      private

      def actions_by(ticket, thread)
        on_update_params = { channel_id: channel_id, thread_ts: ticket.thread_ts.to_s }
        if thread.reactions_by_bot
          remove_result = slack.reactions_remove(on_update_params.merge(name: thread.reactions_by_bot.first["name"])).push
          p "Remove reaction. - Ticket: #{ticket.id}, result: #{remove_result}"
        end
        add_result = slack.reactions_add(on_update_params.merge(name: ticket.reaction_by_status)).push
        on_update_params[:text] = Zendesk::Text.ticket_on_status(ticket.status, ticket.id)
        slack.chat_post_message(on_update_params).push if on_update_params[:text]
        p "Thread reaction include ticket status reaction? - Ticket: #{ticket.id} - #{thread.reaction_include?(ticket.reaction_by_status)}, result: #{add_result}"
      end
    end
  end
end
