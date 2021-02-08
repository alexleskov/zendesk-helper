# frozen_string_literal: true

module Zendesk
  class Client
    HOST = $app_config.call(:zd_host)
    SLACK_THREAD_TS_FIELD_ID = $app_config.call(:slack_thread_ts_field_id)
    SLACK_REPLY_COUNT_FIELD_ID = $app_config.call(:slack_reply_count_field_id)

    attr_reader :access_token, :adapter

    def initialize(client_params = {})
      @adapter = client_params[:adapter] ||= RestClient
      init_access_token(client_params)
    end

    def init_access_token(token_params)
      @access_token = Zendesk::Token.new(token_params)
    end

    def request(headers = {})
      Zendesk::Request.new(default_request_params(headers))
    end

    def ticket(params, headers = {})
      Zendesk::Request::Ticket.new(default_request_params(headers).merge!(params))
    end

    def search(params, headers = {})
      Zendesk::Request::Search.new(default_request_params(headers).merge!(params))
    end

    private

    def default_request_params(headers)
      { client: self, headers: headers }
    end
  end
end
