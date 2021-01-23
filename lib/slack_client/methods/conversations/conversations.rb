# frozen_string_literal: true

module Slack
  class Request
    class Conversations < Slack::Request
      SOURCE = "conversations"

      attr_reader :options, :channel_id

      def initialize(params)
        @options = params[:options]
        @channel_id = params[:channel_id]
        raise "Query must be a Hash" unless options.is_a?(Hash)

        super(client: params[:client], headers: params[:headers])
      end

      def go
        call_api { get("#{request_url}?#{build_channel_param}#{build_url_params}") }
      end

      def request_url
        "#{super}#{SOURCE}"
      end

      private

      def build_url_params
        return "" if options.empty?

        "&#{build_data_by(options, '&', '=')}"
      end

      def build_channel_param
        raise "Must set channel id" unless channel_id

        "channel=#{channel_id}"
      end

      def build_data_by(hashed_options, options_delimeter, values_delimeter)
        return unless hashed_options

        result = []
        hashed_options.each { |option, value| result << [option, value].join(values_delimeter) }
        result.join(options_delimeter)
      end
    end
  end
end
