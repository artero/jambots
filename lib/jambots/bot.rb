require "date"
require "openai"
require "fileutils"
require "yaml"

module Jambots
  class OpenAIMessageError < StandardError; end

  class Bot
    DEFAULT_MODEL = "gpt-4"
    DEFAULT_BOTS_DIR = "#{ENV["HOME"]}/.jambots"

    attr_reader :name, :model, :options, :prompt, :client, :conversations_dir, :bot_dir

    def self.create(
      name:,
      directory: DEFAULT_BOTS_DIR,
      model: DEFAULT_MODEL,
      prompt: nil
    )
      bot_dir = "#{directory}/#{name}"
      FileUtils.mkdir_p(bot_dir) unless Dir.exist?(bot_dir)

      conversations_dir = "#{bot_dir}/conversations"
      FileUtils.mkdir_p(conversations_dir) unless Dir.exist?(conversations_dir)

      bot_yml_path = "#{bot_dir}/bot.yml"
      File.write(bot_yml_path, {model: model, prompt: prompt}.to_yaml) unless File.exist?(bot_yml_path)

      bot_dir
    end

    def initialize(args = {})
      @name = args[:name]
      @model = args[:model] || DEFAULT_MODEL
      @prompt = args[:prompt]

      @client = OpenAI::Client.new(access_token: args[:openai_apy_key])

      @bot_dir = args[:bot_dir]

      @conversations_dir = "#{@bot_dir}/conversations"
      FileUtils.mkdir_p(@conversations_dir) unless Dir.exist?(@conversations_dir)

      # Load options from bot.yml file if it exists
      bot_yml_path = "#{@bot_dir}/bot.yml"
      if File.exist?(bot_yml_path)
        bot_yml_options = YAML.safe_load(File.read(bot_yml_path), permitted_classes: [Symbol], symbolize_names: true)
        args = bot_yml_options.merge(args)
      end

      # Set the model and prompt with the highest priority options
      @model = args[:model] || DEFAULT_MODEL
      @prompt = args[:prompt]
    end

    def message(conversation, text)
      response = client.chat(
        parameters: {
          model: model,
          messages: conversation.messages.insert(-1, {role: "user", content: text}),
          temperature: 0.7
        }
      )

      message = response.dig("choices", 0, "message")

      raise OpenAIMessageError, response if message.nil?

      conversation.add_message("assistant", message[:content])
      conversation.save

      message.transform_keys(&:to_sym)
    end

    def new_conversation
      file_name = generate_conversation_file_name
      file_path = File.join(@conversations_dir, file_name)
      Conversation.new(file_path)
    end

    def list_conversations
      Dir.glob("#{@conversations_dir}/*").map { |file| File.basename(file) }
    end

    def delete_conversation(file_name)
      file_path = File.join(@conversations_dir, file_name)
      conversation = Conversation.new(file_path)
      conversation.delete
    end

    private

    def generate_conversation_file_name
      total_files = Dir.glob("#{@conversations_dir}/*").count
      "#{total_files + 1}.yml"
    end
  end
end
