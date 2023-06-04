# frozen_string_literal: true

module Jambots
  # The Conversation class represents a chat conversation with a Jambots bot.
  # It is used to manage conversation messages, loading and saving conversations, and deleting conversations.
  #
  # @attr_accessor [Array<Hash>] messages The messages in the conversation.
  # @attr_accessor [String] file_name The file name of the conversation file.
  # @attr_accessor [String] file_path The file path of the conversation file.
  # @attr_accessor [String] key The key used to identify the conversation.
  class Conversation
    attr_accessor :messages, :file_name, :file_path, :key

    # Initializes a new Conversation instance with the specified file path.
    #
    # @param file_path [String] The file path of the conversation file.
    def initialize(file_path)
      @file_path = file_path
      @file_name = File.basename(file_path)
      @key = File.basename(file_name, File.extname(file_name))
      @messages = load_messages
    end

    # Adds a message to the conversation.
    #
    # @param role [String] The role of the message sender ("user" or "assistant").
    # @param content [String] The content of the message.
    def add_message(role, content)
      @messages << {role: role, content: content}
    end

    # Saves the conversation to the specified file path.
    def save
      messages_transformed = @messages.map { |message| message.transform_keys(&:to_s) }
      File.write(@file_path, messages_transformed.to_yaml)
    end

    # Loads messages from the conversation file and returns an array of messages.
    #
    # @return [Array<Hash>] The messages in the conversation.
    def load_messages
      return [] unless File.exist?(@file_path)

      file_content = File.read(@file_path)

      YAML.safe_load(file_content, permitted_classes: [Symbol], symbolize_names: true)
    end

    # Deletes the conversation file.
    def delete
      File.delete(@file_path) if File.exist?(@file_path)
    end
  end
end
