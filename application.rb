# frozen_string_literal: true

require 'rest-client'
require 'singleton'
require 'rufus-scheduler'
require 'i18n'

require './lib/app_configurator'
$app_config = AppConfigurator.instance
$app_config.configure

require './lib/request'

require './lib/client/client'
require './lib/client/token'
require './lib/client/request'
require './lib/client/ticket'
require './lib/client/text/text'
require './lib/client/methods/ticket'
require './lib/client/methods/search'

require './lib/slack_client/client'
require './lib/slack_client/token'
require './lib/slack_client/request'
require './lib/slack_client/thread'
require './lib/slack_client/text/text'
require './lib/slack_client/methods/conversations/conversations'
require './lib/slack_client/methods/conversations/history'
require './lib/slack_client/methods/conversations/replies'
require './lib/slack_client/methods/chat/chat'
require './lib/slack_client/methods/chat/post_message'
require './lib/slack_client/methods/reactions/reactions'
require './lib/slack_client/methods/reactions/add'
require './lib/slack_client/methods/reactions/remove'

require './lib/snitcher/snitcher'
require './lib/snitcher/thread'
require './lib/snitcher/ticket'
require './lib/snitcher/pattern/pattern'
require './lib/snitcher/pattern/default'
