# frozen_string_literal: true

module Zendesk
  class Ticket
    STATUSES = { "new" => "new", "pending" => "alarm_clock", "hold" => "construction",
                 "solved" => "white_check_mark", "closed" => "checkered_flag", "open" => "rocket" }.freeze

    attr_reader :thread_ts_field_id, :reply_count_field_id, :thread_ts, :reply_count, :custom_fields, :status, :id

    def initialize(params)
      @thread_ts_field_id = params[:thread_ts_field_id]
      @reply_count_field_id = params[:reply_count_field_id]
      init_attributes(params[:ticket_data])
    end

    def reply_count_equal?(reply_count_value)
      reply_count.to_i == reply_count_value.to_i
    end

    def reaction_by_status
      STATUSES[status]
    end

    def fetch_field_data(fields_data, field_id)
      fields_data.select do |field_data|
        field_data["id"].to_i == field_id && value_exists?(field_data["value"])
      end
    end

    private

    def init_attributes(ticket_data)
      return unless ticket_data

      @custom_fields = ticket_data["custom_fields"]
      @status = ticket_data["status"]
      @id = ticket_data["id"]
      @thread_ts = value_by(:thread_ts, custom_fields)
      @reply_count = value_by(:reply_count, custom_fields).to_i
    end

    def value_by(field_type, fields_data)
      field_id =
        case field_type
        when :thread_ts
          thread_ts_field_id
        when :reply_count
          reply_count_field_id
        end
      data = fetch_field_data(fields_data, field_id)
      return 0 if data.empty?

      data.first["value"]
    end

    def value_exists?(value)
      return unless value

      !value.empty?
    end
  end
end
