# frozen_string_literal: true

require "date"
require "openai"
require "fileutils"
require "yaml"

module Jambots
  class Bot
    DEFAULT_MODEL = "gpt-3.5-turbo"
    DEFAULT_GLOBAL_BOTS_DIR = "#{ENV["HOME"]}/.jambots"
    DEFAULT_LOCAL_BOTS_DIR = "./.jambots"

    attr_reader :name, :model, :options, :prompt, :client, :bot_dir, :current_conversation

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

    def self.find_path(path = nil)
      return path if path

      Dir.exist?(DEFAULT_LOCAL_BOTS_DIR) ? DEFAULT_LOCAL_BOTS_DIR : DEFAULT_GLOBAL_BOTS_DIR
    end

    def initialize(name, args = {})
      @bot_dir = "#{find_path(args[:path])}/#{name}"

      bot_yml_path = "#{@bot_dir}/bot.yml"

      bot_options = load_bot_options(bot_yml_path)
      args = bot_options.merge(args)

      @client = chat_client_factory(args)

      @name = name
      @model = args[:model] || DEFAULT_MODEL
      @prompt = args[:prompt]

      FileUtils.mkdir_p(conversations_dir) unless Dir.exist?(conversations_dir)
    end

    def message(text, conversation)
      conversation.add_message("user", text)
      chat_response = client.chat(chat_client_options(conversation.messages))
      conversation.add_message("assistant", chat_response)
      conversation.save
      conversation.messages.last
    end

    def chat_client_options(messages)
      {
        model: model,
        messages: messages
      }
    end

    def conversations
      Dir.glob("#{conversations_dir}/*").map do |file|
        Conversation.new(file)
      end
    end

    def new_conversation
      new_conversation_path = "#{conversations_dir}/#{Time.now.strftime("%Y%m%d%H%M%S")}.yml"
      conversation = Conversation.new(new_conversation_path)
      conversation.add_message("system", prompt.to_s)
      conversation
    end

    def load_conversation(conversation_name)
      return nil unless conversation_name

      conversation_path = Dir.glob("#{conversations_dir}/#{conversation_name}*").first

      return nil unless conversation_path
      return nil unless File.exist?(conversation_path)

      Conversation.new(conversation_path)
    end

    private

    def find_path(this_path = nil)
      self.class.find_path(this_path)
    end

    def conversations_dir
      "#{bot_dir}/conversations"
    end

    def generate_conversation_file_name
      total_files = Dir.glob("#{@conversations_dir}/*").count
      "#{total_files + 1}.yml"
    end

    def load_bot_options(bot_yml_path)
      raise "Bot #{name} doesn't exist." unless File.exist?(bot_yml_path)

      YAML.safe_load(File.read(bot_yml_path), permitted_classes: [Symbol], symbolize_names: true)
    end

    def chat_client_factory(options = {})
      client_classes = {
        default: Clients::OpenAIClientClient,
        open_ai: Clients::OpenAIClientClient
      }

      client_class = (options[:client] && client_classes[options[:client]]) || client_classes[:default]

      client_class.new(client_options(options))
    end

    def client_options(options)
      options[:client_options] || {}
    end
  end
end
