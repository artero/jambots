require "thor"

module Jambots
  class Cli < Thor
    DEFAULT_BOT = "jambot"

    desc "init", "Initialize a jambots path"
    option :path, aliases: "-p", desc: "Initialize a jambots directory in specific path"
    option :globally, type: :boolean, aliases: "-g", desc: "Creates the jambots directory in the user's root directory"
    def init
      init_controller = Controllers::InitController.new(options)
      init_controller.init_jambots_path
    end

    desc "chat MESSAGE", "Start a chat with the bot and send a message"
    option :bot, aliases: "-b", desc: "Name of the bot"
    option :conversation, aliases: "-c", desc: "Name of the conversation key"
    option :path, aliases: "-p", desc: "Path where the bot and the conversation directory are located"
    option :last, type: :boolean, aliases: "-l", desc: "Continue with the last conversation created"
    option :no_pretty, type: :boolean, aliases: "-n", desc: "Disables pretty formatting"
    def chat(query)
      chat_controller = Controllers::ChatController.new(options)
      chat_controller.chat(query)
    end

    desc "new NAME", "Create a new bot with the specified name"
    option :path, aliases: "-p", desc: "Directory where the bot will be created"
    option :model, desc: "AI model to use"
    option :prompt, desc: "Introduction text for the bot"
    def new(name)
      new_controller = Controllers::NewController.new(options)
      new_controller.create_bot(name)
    end

    private

    def renderer
      @renderer ||= Renderer.new
    end
  end
end
