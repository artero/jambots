require "thor"
require "pastel"

module Jambots
  class Cli < Thor
    def self.exit_on_failure?
      false
    end

    DEFAULT_BOT = "jambot"

    desc "init", "Initialize a jambots path"
    option :path, aliases: "-p", desc: "Initialize a jambots directory in specific path"
    option :globally, type: :boolean, aliases: "-g", desc: "Creates the jambots directory in the user's root directory"
    def init
      init_controller = Controllers::InitController.new(options)
      init_controller.init_jambots_path
    end

    no_commands do
      def self.shared_options
        method_option :bot, aliases: "-b", desc: "Name of the bot"
        method_option :conversation, aliases: "-c", desc: "Name of the conversation key"
        method_option :path, aliases: "-p", desc: "Path where the bot and the conversation directory are located"
        method_option :last, type: :boolean, aliases: "-l", desc: "Continue with the last conversation created"
        method_option :no_pretty, type: :boolean, aliases: "-n", desc: "Disables pretty formatting"
      end
    end
    desc "chat MESSAGE", "Start a chat with the bot and send a message"
    shared_options
    def chat(query)
      conversation_info
      bot_response(query)
    rescue Jambots::ChatClientError => e
      warn "ERROR: #{e.message}"
      exit(1)
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

    def bot
      @bot ||= Bot.new(options[:bot] || DEFAULT_BOT, options)
    end

    def bot_response(query)
      bot.chat(query) do |chunk|
        print options[:no_pretty] ? chunk : pastel.yellow(chunk)
      end
      puts ""
    end

    def conversation_info
      puts bot.conversation.key
    end

    def pastel
      @pastel ||= Pastel.new
    end
  end
end
