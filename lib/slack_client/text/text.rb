# frozen_string_literal: true

module Slack
  class Text
    class << self
      def message(user, text)
        "#{I18n.t('user')}: #{user}\n#{I18n.t('message')}:\n#{text}\n"
      end
    end
  end
end
