# frozen_string_literal: true

module Slack
  class Request
    class Reactions < Slack::Request
      SOURCE = "reactions"

      attr_reader :channel_id, :name, :thread_ts

      def initialize(params)
        @channel_id = params[:channel_id]
        @name = params[:name]
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
        data["timestamp"] = thread_ts if thread_ts
        data["name"] = name if name
        return if data.empty?

        data
      end
    end
  end
end