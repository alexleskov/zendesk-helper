# frozen_string_literal: true

module Zendesk
  class ApiServer
    class << self
      def location_regexp(path = "\\w*")
        %r{^#{$app_config.default_location_webhooks_endpoint}\/(#{path})\/(\d*)}
      end
    end

    def call(env)
      Thread.new do
        @env = env
        request = find_request_by_webhook_path
        return render(403) unless request

        #Zendesk::Webhook::Catcher.new(request)
      render(200)
    rescue StandardError => e
      render(500, e.message)
    end

    private

    def find_request_by_webhook_path
      on "webhooks_catcher" do
        Zendesk::ApiServer::Request.new(@env)
      end
    end

    def on(path)
      location = @env["REQUEST_PATH"].match(Zendesk::ApiServer.location_regexp(path))
      return unless location

      location[1]
      yield
    end

    class Request
      CATCHING_PARAMS = %w[HTTP_HOST REQUEST_PATH REQUEST_METHOD CONTENT_TYPE].freeze

      attr_reader :payload, :http_host, :request_path, :request_method, :content_type

      def initialize(env)
        @env = env
        data = fetch_data
        @payload = data["BODY"]
        @http_host = data["HTTP_HOST"]
        @request_path = data["REQUEST_PATH"]
        @request_method = data["REQUEST_METHOD"]
        @content_type = data["CONTENT_TYPE"]
      end

      private

      def body
        return unless @env["REQUEST_METHOD"] == "POST"

        payload = @env["rack.input"].string
        JSON.parse(payload)
      end

      def fetch_data
        { "BODY" => body }.compact.merge(@env.slice(*CATCHING_PARAMS))
      end
    end

  end
end