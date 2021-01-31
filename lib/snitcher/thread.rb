# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Thread < Zendesk::Snitcher
      def do_action(ticket, thread, options)
        actions_by(ticket, thread, options) unless thread.reaction_include?(ticket.reaction_by_status)
      end

      private

      def actions_by(ticket, thread, _options)
        on_update_params = { channel_id: channel_id, thread_ts: ticket.thread_ts.to_s }
        if thread.reactions_by_bot && !thread.reactions_by_bot.empty?
          on_update_params[:name] = thread.reactions_by_bot.first["name"]
          slack.reactions_remove(on_update_params).push
        end
        on_update_params[:name] = ticket.reaction_by_status
        slack.reactions_add(on_update_params).push
        on_update_params[:text] = Zendesk::Text.ticket_on_status(ticket.status, ticket.id)
        slack.chat_post_message(on_update_params).push if on_update_params[:text]
      end
    end
  end
end
