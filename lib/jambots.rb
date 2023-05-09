# frozen_string_literal: true

require_relative "jambots/version"
require_relative "jambots/bot"
require_relative "jambots/conversation"
require_relative "jambots/cli"
require_relative "jambots/renderers/cli_renderer"
require_relative "jambots/renderers/minimal_renderer"
require_relative "jambots/controllers/init_controller"
require_relative "jambots/controllers/chat_controller"
require_relative "jambots/controllers/new_controller"

module Jambots
  class Error < StandardError; end
  # Your code goes here...
end
