# frozen_string_literal: true

require "date"
require "openai"
require "fileutils"
require "yaml"

module Jambots
  # The Bot class is the main class for Jambots. It is used to create and interact with bots.
  # A bot allows the user to chat with an AI model through chat client classes (e.g., Jambots::Clients::OpenAIClientClient).
  # The class enables creating a new bot, loading an existing bot, and managing conversations with the bot.
  #
  # @attr_reader [String] name The name of the chatbot.
  # @attr_reader [String] model The AI model used by the chatbot, the client must to accept that model (e.g., "gpt-3.5-turbo" for Jambots::Clients::OpenAIClientClient).
  # @attr_reader [Hash] options Additional options for the chatbot.
  # @attr_reader [String] prompt Used as context for the chatbot, allowing customization of chatbot instructions.
  # @attr_reader [Jambots::Clients::AbstractChatClient] client The chat client used by the chatbot (e.g., Jambots::Clients::OpenAI).
  # @attr_reader [String] bot_dir The directory where the chatbot's data is stored.
  # @attr_accessor [Jambots::Conversation] conversation The current conversation of the chatbot.
  class Bot
    DEFAULT_MODEL = "gpt-3.5-turbo"
    DEFAULT_GLOBAL_BOTS_DIR = "#{ENV["HOME"]}/.jambots"
    DEFAULT_LOCAL_BOTS_DIR = "./.jambots"

    attr_reader :name, :model, :options, :prompt, :client, :bot_dir
    attr_accessor :conversation
    # Creates a new bot with the specified name. Creates a new bot directory and bot.yml file for for this bot.
    #
    #
    # @example
    #  Jambots::Bot.create(
    #    test_bot",
    #    path: "./tmp/bots",
    #    model: "gpt-3.5-turbo",
    #    prompt: "You will act as a customer service representative for a company that sells widgets."
    #  )
    #
    # @param name [String] the name of the bot
    # @param path [String] (optional) the path to the bots directory (Default: ~/.jambots)
    # @param model [String] (optional) the model to use for the bot (Default: DEFAULT_MODEL)
    # @param prompt [String] (optional) the prompt to use for the bot (Default: nil)
    # @return [Jambots::Bot] the new bot
    def self.create(
      name,
      path: DEFAULT_BOTS_DIR,
      model: DEFAULT_MODEL,
      prompt: nil
    )
      bot_dir = "#{path}/#{name}"
      FileUtils.mkdir_p(bot_dir) unless Dir.exist?(bot_dir)
      conversations_dir = "#{bot_dir}/conversations"
      FileUtils.mkdir_p(conversations_dir) unless Dir.exist?(conversations_dir)
      bot_yml_path = "#{bot_dir}/bot.yml"
      raise "The bot file #{bot_yml_path} already exists" if File.exist?(bot_yml_path)

      bot_options = {
        model: model,
        prompt: prompt
      }

      bot_options_transformed = bot_options.transform_keys(&:to_s)
      File.write(bot_yml_path, bot_options_transformed.to_yaml)

      new(name, path: path)
    end

    # Returns the path to the bots directory in the current directory (./.jambots)
    # or the home directory (~/.jambots)
    #
    # @param path [String] the path to the bots directory
    # return [String] the path to the jambots directory
    def self.find_path(path = nil)
      return path if path

      Dir.exist?(DEFAULT_LOCAL_BOTS_DIR) ? DEFAULT_LOCAL_BOTS_DIR : DEFAULT_GLOBAL_BOTS_DIR
    end

    # Initializes a new bot
    #
    #
    # @example
    #  Jambots::Bot.new(
    #    "test_bot",
    #    path: "./tmp/bots",
    #    model: "gpt-3.5-turbo",
    #    prompt: "You will act as a customer service representative for a company that sells widgets."
    #  )
    #
    # @param name [String] The name of the bot.
    # @param args [Hash] (optional) The arguments for the bot, that options overwrite the bot options in the bot file ([jambots_path]/[bot_name]/bot.yml).
    # @option args [String, nil] :path The path to the bots directory.
    # @option args [String, nil] :model The model to use for the bot.
    # @option args [String, nil] :prompt The prompt to use for the bot.
    # @option args [Boolean, nil] :last To load the last conversation to use for the bot.
    # @option args [String, nil] :conversation To load a specific conversation to use for the bot.
    # @option args [Symbol, nil] :client The chat client to use for the bot (Default: :default).
    # @option args [Hash, nil] :client_options The options to use for the chat client.
    def initialize(name, args = {})
      args = args.transform_keys(&:to_sym)
      @bot_dir = "#{find_path(args[:path])}/#{name}"

      bot_yml_path = "#{@bot_dir}/bot.yml"

      bot_options = load_bot_options(bot_yml_path)
      args = bot_options.merge(args)

      @client = chat_client_factory(args)

      @name = name
      @model = args[:model] || DEFAULT_MODEL
      @prompt = args[:prompt]

      @conversation = previous_conversation(args) || new_conversation
    end

    def chat(text, &block)
      conversation.add_message("user", text)
      messages = conversation.messages
      content = ""
      client.chat(chat_client_options(messages)) do |chunk|
        content += chunk if chunk
        block.call(chunk)
      end
      conversation.add_message("assistant", content)
      conversation.save
      conversation.messages.last
    end

    # Return a list of all conversations for the bot.
    # The bot conversations are YML files in the  conversations directory in the `bot_dir`.
    #
    # @example
    #  bot.conversations
    #
    # @return [Array<Jambots::Conversation>] the list of conversations
    def conversations
      Dir.glob("#{conversations_dir}/*").map do |file|
        Conversation.new(file)
      end
    end

    # Create a new conversation for the bot.
    # The bot conversations will stored in the conversations directory in the `bot_dir`.
    #
    # @example
    #  bot.new_conversation
    #
    # @return [Jambots::Conversation] the new conversation
    def new_conversation
      FileUtils.mkdir_p(conversations_dir) unless Dir.exist?(conversations_dir)

      new_conversation_path = "#{conversations_dir}/#{Time.now.strftime("%Y%m%d%H%M%S")}.yml"
      new_conversation = Conversation.new(new_conversation_path)
      new_conversation.add_message("system", prompt.to_s)
      new_conversation
    end

    # Load a conversation from the conversations directory in the `bot_dir`.
    #
    # @example
    #  bot.load_conversation("20210901120000")
    #
    # @param conversation_name [String] The name of the conversation to load.
    # @return [Jambots::Conversation, nil] The conversation or nil if the conversation doesn't exist.
    def load_conversation(conversation_name)
      return nil unless conversation_name

      conversation_path = Dir.glob("#{conversations_dir}/#{conversation_name}*").first

      return nil unless conversation_path
      return nil unless File.exist?(conversation_path)

      Conversation.new(conversation_path)
    end

    private

    def chat_client_options(messages)
      {
        model: model,
        messages: messages
      }
    end

    def previous_conversation(args)
      args[:last] ? conversations.last : load_conversation(args[:conversation])
    end

    # Returns the path to the bots directory in the current directory (./.jambots)
    # or the home directory (~/.jambots)
    #
    # @param this_path [String] the path to the bots directory
    # return [String] the path to the jambots directory
    def find_path(this_path = nil)
      self.class.find_path(this_path)
    end

    # Returns the path to the bots directory in the current directory (./.jambots)
    # or the home directory (~/.jambots)
    #
    # @param this_path [String] The path to the bots directory
    # return [String] The path to the jambots directory
    def conversations_dir
      "#{bot_dir}/conversations"
    end

    # Load the bot options from the bot.yml file in the bot directory.
    #
    # @param bot_yml_path [String] The path to the bot yml file.
    # @return [Hash] The bot options.
    def load_bot_options(bot_yml_path)
      raise "Bot #{name} doesn't exist." unless File.exist?(bot_yml_path)

      YAML.safe_load(File.read(bot_yml_path), permitted_classes: [Symbol], symbolize_names: true)
    end

    # Returns AI client for the bot.
    #
    # @param options [Hash] The options for the chat client.
    # @option options [String] :client The chat client to use for the bot (Default: :default).
    # @option options [Hash] :client_options The options to use for the chat client. Review the chat client documentation.
    def chat_client_factory(options = {})
      client_classes = {
        default: Clients::OpenAIClientClient,
        open_ai: Clients::OpenAIClientClient
      }

      client_class = (options[:client] && client_classes[options[:client]]) || client_classes[:default]

      client_options = options[:client_options] || {}
      client_class.new(client_options)
    end
  end
end
