# frozen_string_literal: true

module Slack
  class Token
    attr_reader :value

    def initialize(params)
      @value = params[:value] || $app_config.call(:slack_access_token)
    end
  end
end
