# frozen_string_literal: true

module Zendesk
  class Token
    SOURCE = "oauth/tokens"

    attr_reader :grant_type,
                :scope,
                :value,
                :type,
                :response

    def initialize(params)
      @adapter = params[:adapter]
      @grant_type = params[:grant_type] || "password"
      @client_id = params[:client_id] || $app_config.call(:zd_client_id)
      @client_secret = params[:client_secret] || $app_config.call(:zd_client_secret)
      @username = params[:username] || $app_config.call(:zd_username)
      @password = params[:password] || $app_config.call(:zd_password)
      @scope = params[:scope] || "read write"
      @headers = params[:headers] || default_headers
    end

    def create
      return self if value

      call_to_api
      raise "Can't call access_token by api" unless response

      parsed_body = JSON.parse(response.body)
      @type = parsed_body["token_type"]
      @value = parsed_body["access_token"]
      @scope = parsed_body["scope"]
      self
    end

    def call_to_api
      @response = @adapter.post(request_url, build_payload, @headers)
    rescue @adapter::ExceptionWithResponse => e
      case e.http_code
      when 301, 302, 307
        e.response.follow_redirection
      else
        raise e, "Unexpected error with token requesting: Code: #{e.http_code}. Response: #{e.response}"
      end
    end

    def request_url
      "#{Zendesk::Client::HOST}#{SOURCE}"
    end

    private

    def build_payload
      { grant_type: grant_type, client_id: @client_id, client_secret: @client_secret, username: @username,
        password: @password, scope: scope }
    end

    def default_headers
      { "Content-Type" => "application/json" }
    end
  end
end
