require "thor"

module Jambots
  class Cli < Thor
    DEFAULT_BOT = "jambot"

    desc "chat MESSAGE", "Start a chat with the bot and send a message"
    option :bot, aliases: "-b", desc: "Name of the bot"
    option :conversation, aliases: "-c", desc: "Name of the conversation file"
    option :path, desc: "Path where the bot and the conversation directory are located"
    option :last, type: :boolean, aliases: "-l", desc: "Continue with the last conversation created"
    def chat(query)
      bot = Bot.new(
        options[:bot] || DEFAULT_BOT,
        path: options[:path] || Jambots::Bot::DEFAULT_BOTS_DIR
      )

      last = options[:last]
      previous_conversation = last ? bot.conversations.last : bot.load_conversation(options[:conversation])
      conversation = previous_conversation || bot.new_conversation

      renderer.spinner.auto_spin
      message = bot.message(query, conversation)
      renderer.spinner.success
      renderer.render(message, conversation)
    end

    desc "new NAME", "Create a new bot with the specified name"
    option :directory, desc: "Directory where the bot will be created"
    option :model, desc: "AI model to use"
    option :prompt, desc: "Introduction text for the bot"
    def new(name)
      directory = options[:directory] || Jambots::Bot::DEFAULT_BOTS_DIR
      model = options[:model] || Jambots::Bot::DEFAULT_MODEL
      prompt = options[:prompt]

      Jambots::Bot.create(name, directory: directory, model: model, prompt: prompt)
      puts "Bot '#{name}' created in the directory '#{directory}'."
    end

    private

    def renderer
      @renderer ||= Renderer.new
    end
  end
end
