require "thor"

module Jambots
  class Cli < Thor
    def self.exit_on_failure?
      false
    end

    no_commands do
      def self.chat_options
        desc "chat MESSAGE", "Start a chat with the bot and send a message"
        method_option :bot, aliases: "-b", desc: "Name of the bot"
        method_option :conversation, aliases: "-c", desc: "Name of the conversation key"
        method_option :path, aliases: "-p", desc: "Path where the bot and the conversation directory are located"
        method_option :last, type: :boolean, aliases: "-l", desc: "Continue with the last conversation created"
        method_option :no_pretty, type: :boolean, aliases: "-n", desc: "Disables pretty formatting"
      end

      def self.init_options
        desc "init", "Initialize a jambots path"
        method_option :path, aliases: "-p", desc: "Initialize a jambots directory in specific path"
        method_option :globally, type: :boolean, aliases: "-g", desc: "Creates the jambots directory in the user's root directory"
      end

      def self.new_options
        desc "new NAME", "Create a new bot with the specified name"
        option :path, aliases: "-p", desc: "Directory where the bot will be created"
        option :model, desc: "AI model to use"
        option :prompt, desc: "Introduction text for the bot"
      end
    end

    DEFAULT_BOT = "jambot"

    init_options
    def init
      init_controller = Controllers::InitController.new(options)
      init_controller.init_jambots_path
    end

    chat_options
    def chat(query)
      chat_controller = Controllers::ChatController.new(options)
      chat_controller.chat(query)
    end

    new_options
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
