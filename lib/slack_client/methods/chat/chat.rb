# frozen_string_literal: true

module Slack
  class Request
    class Chat < Slack::Request
      SOURCE = "chat"

      attr_reader :channel_id, :text, :thread_ts

      def initialize(params)
        @channel_id = params[:channel_id]
        @text = params[:text]
        @thread_ts = params[:thread_ts]

        super(client: params[:client], headers: params[:headers])
      end

      def push
        call_api { post("#{request_url}", build_payload) }
      end

      def request_url
        "#{super}#{SOURCE}"
      end

      private

      def build_payload
        data = {}
        data["channel"] = channel_id.to_s if channel_id
        data["thread_ts"] = thread_ts if thread_ts
        data["username"] = "Support Helper"
        data["icon_emoji"] = ":godmode:"
        data["mrkdwn"] = true
        data["blocks"] = [{"type" => "section", "text" => {"type" => "mrkdwn", "text" => text.to_s}}] if text
        return if data.empty?

        data
      end
    end
  end
end