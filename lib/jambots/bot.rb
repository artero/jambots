require "date"
require "openai"
require "fileutils"

module Jambots
  class OpenAIMessageError < StandardError; end

  class Bot
    DEFAULT_MODEL = "gpt-3.5-turbo"
    DEFAULT_NAME = "JamBot"
    DEFAULT_PATH = "#{ENV["HOME"]}/.jambots"

    attr_reader :model,
      :face,
      :history_file_path,
      :history_file,
      :name,
      :user_name,
      :options,
      :prompt,
      :messages

    def initialize(args = {})
      actual_date = Time.now.strftime("%Y%m%d")
      @user_name = args[:user_name]
      @name = args[:name] || DEFAULT_NAME
      @face = args[:face]
      @model = args[:model] || DEFAULT_MODEL
      @prompt = args[:prompt]
      @options = {
        record_history: !(args[:record_history] == false),
        jambots_dir: args[:jambots_dir] || DEFAULT_PATH,
        openai_apy_key: args[:openai_apy_key],
        log: args[:log]
      }

      # initialize
      unless Dir.exist?("#{options[:jambots_dir]}/history")
        FileUtils.mkdir_p("#{options[:jambots_dir]}/history")
      end
      # TODO Create a bot.yml file with default options

      @history_file = "#{args[:name]}_history_#{actual_date}.yml"
      @history_file_path = "#{options[:jambots_dir]}/history/#{history_file}"

      @messages = build_messages(args)
    end

    def message(text)
      response = client.chat(
        parameters: {
          model: model, # Required.
          messages: messages.insert(-1, {role: "user", content: text}),
          temperature: 0.7
        }
      )

      puts response if options[:log]

      message = response.dig("choices", 0, "message")

      if message.nil?
        raise OpenAIMessageError, response
      end
      messages.insert(-1, message.transform_keys(&:to_sym)).compact
      update_history if record_history?

      message.transform_keys(&:to_sym)
    end

    def history
      build_messages
    end

    def clean_history
      File.delete(history_file_path) if File.exist?(history_file_path)
    end

    private

    def record_history?
      options[:record_history]
    end

    def build_messages(args = {})
      if record_history? && File.exist?(history_file_path)
        messages_raw = YAML.safe_load(File.read(history_file_path), [Symbol])
        return messages_raw.map { |m| m.transform_keys(&:to_sym) }
      end

      [
        {
          role: "system",
          content: "Your name is #{name}, today is #{Date.today}. "
        }
      ]
    end

    def update_history
      # json_str = JSON.generate(messages)
      # File.write(history_file_path, json_str)
      File.write(history_file_path, messages.to_yaml)
    end

    def client
      @client ||= OpenAI::Client.new(access_token: options[:openai_apy_key])
    end
  end
end
