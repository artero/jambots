# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module Jambots::Controllers
  class ChatController
    DEFAULT_BOT = "jambot"
    DEFAULT_TIMEOUT = 240

    attr_reader :bot, :conversation, :renderer

    def initialize(options)
      bot_name = bot_name(options)
      bot_options = bot_options(options)
      @bot = Jambots::Bot.new(bot_name, bot_options)

      conversation_options = conversation_options(options)
      @conversation = load_conversation(conversation_options)

      @renderer = load_renderer(options)
    end

    def chat(query)
      # bot.message(query, conversation)
      # puts ""
      pastel = Pastel.new

      message = bot.chat(query, conversation) do |chunk|
        print pastel.yellow(chunk)
      end
      puts ""
      puts "----------------------------------------"
      puts message
    end

    def chat_interactive
      puts "#{conversation.key} (#{conversation.file_path})"

      prompt = TTY::Prompt.new(
        prefix: " > ",
        interrupt: :exit,
        enable_color: false
      )

      loop do
        query = prompt.ask("")

        chat(query)
      end
    end

    private

    def bot_name(options)
      options[:bot] || DEFAULT_BOT
    end

    def bot_options(options)
      bot_options = {}
      bot_options[:path] = options[:path] if options[:path]
      bot_options[:model] = options[:model] if options[:model]
      bot_options[:prompt] = options[:prompt] if options[:prompt]
      bot_options[:openai_api_key] = options[:openai_api_key] if options[:openai_api_key]
      bot_options[:request_timeout] = options[:request_timeout] if options[:request_timeout]

      bot_options
    end

    def conversation_options(options)
      {
        conversation: options[:conversation],
        last: options[:last]
      }
    end

    def load_conversation(options)
      last = options[:last]
      previous_conversation = last ? bot.conversations.last : bot.load_conversation(options[:conversation])

      previous_conversation || bot.new_conversation
    end

    def load_renderer(options)
      if options[:no_pretty]
        Jambots::Renderers::MinimalRenderer.new
      else
        Jambots::Renderers::CliRenderer.new
      end
    end
  end
end
