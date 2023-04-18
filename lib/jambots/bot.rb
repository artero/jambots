# frozen_string_literal: true

require "date"
require "openai"
require "fileutils"
require "yaml"

module Jambots
  class OpenAIMessageError < StandardError; end

  class Bot
    DEFAULT_MODEL = "gpt-4"
    DEFAULT_BOTS_DIR = "#{ENV["HOME"]}/.jambots"

    attr_reader :name, :model, :options, :prompt, :client, :bot_dir, :current_conversation

    def self.create(
      name,
      directory: DEFAULT_BOTS_DIR,
      model: DEFAULT_MODEL,
      prompt: nil
    )
      bot_dir = "#{directory}/#{name}"
      FileUtils.mkdir_p(bot_dir) unless Dir.exist?(bot_dir)
      conversations_dir = "#{bot_dir}/conversations"
      FileUtils.mkdir_p(conversations_dir) unless Dir.exist?(conversations_dir)

      bot_yml_path = "#{bot_dir}/bot.yml"
      raise "The bot file #{bot_yml_path} already exists" if File.exist?(bot_yml_path)

      bot_options = {
        model: model,
        prompt: prompt
      }

      mi_hash = bot_options.transform_keys(&:to_s)
      File.write(bot_yml_path, mi_hash.to_yaml)

      new(name, bot_dir: bot_dir)
    end

    def initialize(name, args = {})
      @bot_dir = args[:bot_dir] || "#{DEFAULT_BOTS_DIR}/#{name}"

      raise "Bot #{name} doesn't exist." unless File.exist?("#{bot_dir}/bot.yml")

      # Load options from bot.yml file if it exists
      bot_yml_path = "#{@bot_dir}/bot.yml"
      if File.exist?(bot_yml_path)
        bot_yml_options = YAML.safe_load(File.read(bot_yml_path), permitted_classes: [Symbol], symbolize_names: true)
        args = bot_yml_options.merge(args)
      end

      openai_api_key = args[:openai_api_key] || ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: openai_api_key)

      @name = name
      @model = args[:model] || DEFAULT_MODEL
      @prompt = args[:prompt]

      FileUtils.mkdir_p(conversations_dir) unless Dir.exist?(conversations_dir)
    end

    def message(text, conversation)
      response = client.chat(
        parameters: {
          model: model,
          messages: conversation.messages.insert(-1, {role: "user", content: text}),
          temperature: 0.7
        }
      )

      message = response.dig("choices", 0, "message")

      raise OpenAIMessageError, response if message.nil?

      conversation.add_message("assistant", message["content"])
      conversation.save
      conversation.messages.last
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

    def conversations_dir
      "#{bot_dir}/conversations"
    end

    def generate_conversation_file_name
      total_files = Dir.glob("#{@conversations_dir}/*").count
      "#{total_files + 1}.yml"
    end
  end
end
