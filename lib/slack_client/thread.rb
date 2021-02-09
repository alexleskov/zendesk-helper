# frozen_string_literal: true

module Slack
  class Thread
    REPLIES_LIMIT = 100

    attr_reader :reply_count, :messages, :reactions_by_bot, :ts

    def initialize(params)
      init_attributes(params[:thread_data])
    end

    def last_reply_by_bot?
      return unless messages.last && messages.last["subtype"]

      messages.last["subtype"] && messages.last["subtype"] == "bot_message"
    end

    def to_comments(messages_list)
      result = []
      messages_list.each do |message|
        next unless message["user"]

        result << Slack::Text.message(message["user"], message["text"])
      end
      result.join("\n")
    end

    def reaction_include?(emoji_name)
      return unless reactions_by_bot

      result = reactions_by_bot.select { |reaction| reaction["name"].to_s == emoji_name.to_s }
      return if result.empty?

      result
    end

    private

    def init_attributes(thread_data)
      return unless thread_data

      @messages = thread_data["messages"]
      @reply_count = messages.first["reply_count"]
      @ts = messages.first["ts"]
      @reactions_by_bot = find_reactions_by_bot($app_config.call(:slack_bot_user_id))
    end

    def find_reactions_by_bot(bot_id)
      reactions_data = messages.first["reactions"]
      return unless reactions_data

      result = reactions_data.select { |reaction| reaction["users"].include?(bot_id.to_s) }
      return if result.empty?

      result
    end
  end
end
