require "date"
require "openai"

module Jambots
  class Bot
    attr_reader :history_file, :history_file_path, :name, :user_name, :face, :messages, :options

    def initialize(args = {})
      actual_date = Time.now.strftime("%Y%m%d")

      # binding.irb
      @history_file = "#{args[:name]}_history_#{actual_date}.yml"
      @history_file_path = "#{File.dirname($0)}/histories/#{history_file}.json"
      @user_name = args[:user_name]
      @face = args[:face]
      @options = {
        record_history: args[:record_history] == false ? false : true,
        openai_apy_key: args[:openai_apy_key]
      }
      @messages = build_messages(args)
    end

    def message(text)
      # messages = if File.exist?(history_file_path)
      #   JSON.parse(File.read(history_file_path))
      # else
      #   [
      #     {
      #       role: "system",
      #       content: "Your name is #{name} and user's name is #{user_name}, today is #{Date.today}. #{prompt}"
      #     }
      #   ]
      # end

      # spinner.auto_spin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo", # Required.
          messages: messages.insert(-1, {role: "user", content: text}),
          temperature: 0.7
        }
      )
      # spinner.success

      # puts "( #{face} )  <───────────────────────────────────────────"
      # puts ""
      # puts pastel.magenta(response.dig("choices", 0, "message", "content"))
      # puts "────────────────────────────────────────────────────"
      messages.insert(-1, response.dig("choices", 0, "message")).compact

      # Write JSON
      # binding.irb
      update_history if record_history?
      messages
    end

    private

    def record_history?
      options[:record_history]
    end

    def build_messages(args = {})
      return JSON.parse(File.read(history_file_path)) if record_history? && File.exist?(history_file_path)

      [
        {
          role: "system",
          content: "Your name is #{name}, today is #{Date.today}. #{args[:prompt]}"
        }
      ]
    end

    def update_history
      json_str = JSON.generate(messages)
      File.write(history_file_path, json_str)
    end

    def client
      @client ||= OpenAI::Client.new(access_token: options[:openai_apy_key])
    end
  end
end
