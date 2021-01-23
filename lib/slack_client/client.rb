# frozen_string_literal: true

module Slack
  class Client
    HOST = $app_config.call(:slack_host)
    CHANNELS_IDS = { support_operations: "C58EJNB6D" }

    attr_reader :access_token, :adapter

    def initialize(client_params = {})
      @adapter ||= RestClient
      set_access_token(client_params)
    end

    def set_access_token(token_params)
      @access_token = Slack::Token.new(token_params)
    end

    def request(headers = {})
      Slack::Request.new(default_request_params(headers))
    end

    def conversations_history(params, headers = {})
      Slack::Request::Conversations::History.new(default_request_params(headers).merge!(params))
    end

    def conversations_replies(params, headers = {})
      Slack::Request::Conversations::Replies.new(default_request_params(headers).merge!(params))
    end

    def chat_post_message(params, headers = {})
      Slack::Request::Chat::PostMessage.new(default_request_params(headers).merge!(params))
    end

    def reactions_add(params, headers = {})
      Slack::Request::Reactions::Add.new(default_request_params(headers).merge!(params))
    end

    def reactions_remove(params, headers = {})
      Slack::Request::Reactions::Remove.new(default_request_params(headers).merge!(params))
    end

    private

    def default_request_params(headers)
      { client: self, headers: headers }
    end
  end
end
