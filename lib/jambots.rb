# frozen_string_literal: true

require_relative "jambots/version"
require_relative "jambots/bot"
require_relative "jambots/conversation"
require_relative "jambots/cli"
require_relative "jambots/clients/abstract_chat_client"
require_relative "jambots/clients/open_ai_client"
require_relative "jambots/controllers/init_controller"
require_relative "jambots/controllers/new_controller"

module Jambots
  class Error < StandardError; end

  class ChatClientError < Error; end
end
