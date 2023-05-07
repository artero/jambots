# frozen_string_literal: true

module Jambots::Controllers
  class ChatController
    DEFAULT_BOT = "jambot"

    def initialize(options)
      @options = options
      @renderer = Jambots::Renderer.new
    end

    def chat(query)
      bot = Jambots::Bot.new(
        @options[:bot] || DEFAULT_BOT,
        path: Jambots::Bot.find_path(@options[:path])
      )

      last = @options[:last]
      previous_conversation = last ? bot.conversations.last : bot.load_conversation(@options[:conversation])

      conversation = previous_conversation || bot.new_conversation

      @renderer.spinner.auto_spin
      message = bot.message(query, conversation)
      @renderer.spinner.success
      @renderer.render(message, conversation)
    end
  end
end
