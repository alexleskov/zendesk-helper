# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Thread < Zendesk::Snitcher
      def update(options)
        updated_ids = []
        tickets = super
        return unless tickets

        tickets.each do |ticket|
          zd_thread_ts = zd_value_by(:thread_ts, ticket["custom_fields"])
          bot_reaction = find_thread_reaction(zd_thread_ts)
          p "t_id: #{ticket["id"]}, bot_reaction: #{bot_reaction}, reaction_by_zd: #{reaction_by(ticket["status"])}"
          if bot_reaction && bot_reaction.first
            unless reaction_equal?(bot_reaction.first["name"], reaction_by(ticket["status"]))
              #remove_reaction(bot_reaction.first["name"], zd_thread_ts)
              #set_reaction(reaction_by(ticket["status"]), zd_thread_ts)
              #notify_thread_about_status(ticket["status"], ticket["id"], zd_thread_ts)
              updated_ids << ticket["id"]
            end
          elsif !bot_reaction
            #set_reaction(reaction_by(ticket["status"]), zd_thread_ts)
            #notify_thread_about_status(ticket["status"], ticket["id"], zd_thread_ts)
            updated_ids << ticket["id"]
          end
        end
        p "Threads. by: #{options[:by]}, updated_ids: #{updated_ids}"
        updated_ids
      end

      private

      def find_thread_reaction(thread_ts)
        reactions = slack_thread(thread_ts, 1)["messages"].first["reactions"]
        return unless reactions

        reactions.select do |reaction|
          reaction["users"].include?($app_config.call(:slack_bot_user_id).to_s)
        end
      end

      def reaction_equal?(current_emoji_name, new_emoji_name)
        current_emoji_name.to_s == new_emoji_name.to_s
      end

      def reaction_by(status)
        Zendesk::Request::Ticket::STATUSES[status]
      end

      def remove_reaction(emoji_name, thread_ts)
        slack.reactions_remove(name: emoji_name, channel_id: channel_id, thread_ts: thread_ts).push
      end

      def set_reaction(emoji_name, thread_ts)
        slack.reactions_add(name: emoji_name, channel_id: channel_id, thread_ts: thread_ts).push
      end

      def notify_thread_about_status(status, ticket_id, thread_ts)
        text = Zendesk::Text.ticket_on_status(status, ticket_id)
        return unless text

        send_message(text, thread_ts)
      end
    end
  end
end
