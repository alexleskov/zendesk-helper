# frozen_string_literal: true

module Zendesk
  class Snitcher
    class Ticket < Zendesk::Snitcher

      def update(options)
        tickets = super
        return unless tickets

        tickets.each do |ticket|
          Thread.new do
            zd_thread_ts = zd_value_by(:thread_ts, ticket["custom_fields"])
            zd_reply_count = zd_value_by(:reply_count, ticket["custom_fields"])
            s_thread_messages = slack_thread(zd_thread_ts, 100)["messages"]
            s_reply_count = s_thread_messages.first["reply_count"]
            unless reply_count_equal?(zd_reply_count, s_reply_count) || last_reply_by_bot?(s_thread_messages)
              if ticket["status"] == "closed"
                send_message(Zendesk::Text.ticket_closed(ticket["id"]), zd_thread_ts)
              else
                update_comments(ticket["id"], s_thread_messages.drop(zd_reply_count.to_i))
                update_status(ticket["id"], options[:to], s_reply_count)
              end
            end
          end
        end
      end

      private

      def update_status(id, to_status, s_reply_count)
        zendesk.ticket(id: id, status: to_status, custom_fields: [{ "id" => zd_reply_count_field_id,
                                                                    "value" => s_reply_count }] ).update
      end

      def update_comments(id, messages)
        return if messages.empty?

        zendesk.ticket(id: id, comment: thread_messages_to_comments(messages), public_mode: false).update
      end

      def reply_count_equal?(zd_reply_count, s_reply_count)
        zd_reply_count.to_i == s_reply_count.to_i
      end

      def last_reply_by_bot?(messages)
        return false unless messages.last && messages.last["subtype"]

        messages.last["subtype"] && messages.last["subtype"] == "bot_message"
      end
      
      def thread_messages_to_comments(messages)
        result = []
        messages.each do |message|
          result << Slack::Text.message(message["user"], message["text"])
        end
        result.join("\n")
      end
    end
  end
end