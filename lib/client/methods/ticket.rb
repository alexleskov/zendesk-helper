# frozen_string_literal: true

module Zendesk
  class Request
    class Ticket < Zendesk::Request
      SOURCE = "tickets"
      STATUSES = { "new" => "new", "open" => "rocket", "pending" => "alarm_clock", "hold" => "construction",
                   "solved" => "white_check_mark", "closed" => "checkered_flag" }.freeze
      JSON = ".json"

      attr_reader :id,
                  :comment,
                  :public_mode,
                  :status,
                  :subject,
                  :priority,
                  :agent_email,
                  :agent_id,
                  :custom_fields

      def initialize(params)
        @id = params[:id]
        @comment = params[:comment]
        @public_mode = params[:public_mode]
        @status = params[:status]
        @subject = params[:subject]
        @priority = params[:priority]
        @agent_email = params[:agent_email]
        @agent_id = params[:agent_id]
        @custom_fields = params[:custom_fields]
        super(client: params[:client], headers: params[:headers])
      end

      def update
        call_api { put("#{request_url}/#{id}#{JSON}", build_payload) }
      end

      def create
        call_api { post("#{request_url}#{JSON}", build_payload) }
      end

      def request_url
        "#{super}#{SOURCE}"
      end

      private

      def build_payload
        data = { "ticket" => {} }
        data["ticket"]["comment"] = build_comment_data(comment, public_mode) if comment
        data["ticket"]["assignee_email"] = agent_email if agent_email
        data["ticket"]["agent_id"] = agent_id if agent_id
        data["ticket"]["subject"] = subject if subject
        data["ticket"]["priority"] = priority if priority
        data["ticket"]["custom_fields"] = custom_fields if custom_fields
        if status
          raise "No such status '#{status}'. Avaliable: #{STATUSES.keys}" unless STATUSES.keys.include?(status)

          data["ticket"]["status"] = status
        end
        return if data["ticket"].empty?

        data
      end

      def build_comment_data(_text, public_mode = false)
        { "body" => comment, "public" => public_mode }
      end
    end
  end
end
