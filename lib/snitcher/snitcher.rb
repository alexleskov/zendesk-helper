# frozen_string_literal: true

module Zendesk
  class Snitcher
    PER_PAGE = 100

    attr_reader :zendesk, :slack, :channel_id, :zd_thread_ts_field_id, :zd_reply_count_field_id

    def initialize(params = {})
      @zendesk = Zendesk::Client.new
      @slack = Slack::Client.new
      @channel_id = params[:channel_id] || Slack::Client::CHANNELS_IDS[:support_operations]
      @zd_thread_ts_field_id = params[:zd_thread_ts_field_id] || Zendesk::Client::SLACK_THREAD_TS_FIELD_ID.to_i
      @zd_reply_count_field_id = params[:zd_reply_count_field_id] || Zendesk::Client::SLACK_REPLY_COUNT_FIELD_ID.to_i
    end

    def update(options)
      tickets_by(options[:by], zd_thread_ts_field_id)
    end

    protected

    def slack_thread(thread_ts, limit)
      slack.conversations_replies(channel_id: channel_id, options: { limit: limit, ts: thread_ts.to_s }).go
    end

    def send_message(text, thread_ts)
      slack.chat_post_message(text: text, channel_id: channel_id, thread_ts: thread_ts).push
    end

    def tickets_by(status, field_id)
      tickets =
        tickets_list(status)["results"].select do |ticket_data|
          !fetch_field_data(ticket_data["custom_fields"], field_id).empty? && ticket_data["status"] == status
        end
      return unless tickets && !tickets.empty?

      tickets
    end

    def tickets_list(status)
      zendesk.search(query: { type: :ticket, status: status, tags: "slack" },
                     options: { sort_by: "created_at", sort_order: "desc", per_page: Zendesk::Snitcher::PER_PAGE }).go
    end

    def zd_value_by(field_type, custom_fields_data)
      field_id =
        case field_type
        when :thread_ts
          zd_thread_ts_field_id
        when :reply_count
          zd_reply_count_field_id
        end
      data = fetch_field_data(custom_fields_data, field_id)
      return 0 if data.empty?

      data.first["value"]
    end

    def fetch_field_data(fields_hash, field_id)
      fields_hash.select do |field_data|
        field_data["id"].to_i == field_id && value_exists?(field_data["value"])
      end
    end

    def value_exists?(value)
      return unless value

      !value.empty?
    end
  end
end
