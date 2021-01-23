# frozen_string_literal: true

class AppConfigurator
  include Singleton

  attr_reader :tg_bot_client

  def initialize
    @config_file = IO.read('config/secrets.yml')
  end

  def configure
    setup_i18n
    Thread.report_on_exception = true
  end

  def call(option_name)
    YAML.safe_load(@config_file)[option_name.to_s]
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.available_locales = %i[en ru]
    I18n.default_locale = call(:default_locale).to_sym
    I18n.backend.load_translations
  end
end
