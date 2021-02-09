# frozen_string_literal: true

module Zendesk
  class Snitcher
    TICKETS_PER_PAGE = 100
    TICKET_SLACK_TAG = "slack"

    attr_reader :zendesk, :slack, :channel_id, :zd_thread_ts_field_id, :zd_reply_count_field_id

    def initialize(params = {})
      @zendesk = Zendesk::Client.new
      @slack = Slack::Client.new
      @channel_id = params[:channel_id] || Slack::Client::CHANNELS_IDS[:support_operations]
      @zd_thread_ts_field_id = params[:zd_thread_ts_field_id] || Zendesk::Client::SLACK_THREAD_TS_FIELD_ID.to_i
      @zd_reply_count_field_id = params[:zd_reply_count_field_id] || Zendesk::Client::SLACK_REPLY_COUNT_FIELD_ID.to_i
    end

    def update(options)
      updated_ids = []
      replies_limit = options[:replies_limit] || Slack::Thread::REPLIES_LIMIT
      tickets = tickets_by(options[:by], zd_thread_ts_field_id)
      return unless tickets

      tickets.each do |ticket|
        thread = Slack::Thread.new(thread_data: slack_thread_by(ticket.thread_ts, replies_limit))
        action_result = do_action(ticket, thread, options)
        updated_ids << ticket.id if action_result
      end
      updated_ids
    end

    def tickets_by(status, field_id)
      tickets = []
      tickets_list(status)["results"].each do |ticket_data|
        ticket = Zendesk::Ticket.new(ticket_data: ticket_data, thread_ts_field_id: zd_thread_ts_field_id,
                                     reply_count_field_id: zd_reply_count_field_id)
        tickets << ticket if !ticket.fetch_field_data(ticket.custom_fields, field_id).empty? && ticket.status == status.to_s
      end
      return if tickets.empty?

      tickets
    end

    def slack_thread_by(thread_ts, limit)
      slack.conversations_replies(channel_id: channel_id, options: { limit: limit, ts: thread_ts.to_s }).go
    end

    protected

    def tickets_list(status)
      zendesk.search(query: { type: :ticket, status: status, tags: Zendesk::Snitcher::TICKET_SLACK_TAG },
                     options: { sort_by: "created_at", sort_order: "desc", per_page: Zendesk::Snitcher::TICKETS_PER_PAGE }).go
    end
  end
end
