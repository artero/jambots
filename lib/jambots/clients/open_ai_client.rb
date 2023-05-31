# frozen_string_literal: true

require "pastel"

module Jambots
  module Clients
    class OpenAIClientClient < AbstractChatClient
      attr_reader :provider_client

      def initialize(args = {})
        @provider_client = ::OpenAI::Client.new(
          access_token: args[:api_key] || ENV["OPENAI_API_KEY"],
          request_timeout: args[:request_timeout] || 240
        )
      end

      def chat(args = {})
        @output = ""
        if args[:messages].empty?
          raise ArgumentError, "messages must not be empty"
        end

        chat_params = {
          model: args[:model] || "gpt-3.5-turbo",
          messages: args[:messages],
          temperature: args[:temperature] || 0.7,
          stream: proc { |chunk, _bytesize | process_chunk(chunk) }
        }

        @output = @provider_client.chat(parameters: chat_params) if @output == ""

        if @output.nil? || @output == ""
          raise(ChatClientError, "OpenAI response does not contain a message")
        end

        @output
      end

      private

      def process_chunk(chunk)
        if chunk["error"]
          raise ChatClientError, handle_error(chunk)
        end

        part = chunk.dig("choices", 0, "delta", "content")
        @output += part if part
        print part
      end

      def handle_error(response)
        if response.dig("error", "code") == "invalid_api_key"
          <<~HEREDOC
            Invalid OpenAI API key. Please set the OPENAI_API_KEY environment variable to your OpenAI API key.
            You can find your API key at https://beta.openai.com/account/api-keys.
          HEREDOC
        elsif response.dig("error", "code") == "max_tokens"
          <<~HEREDOC
            The chat is too long and exceeds the maximum number of tokens. The chat is very long and exceeds the maximum number of tokens.
            Check the limitations of the model https://platform.openai.com/docs/models/overview
          HEREDOC
        else
          <<~HEREDOC
            OpenAI error - #{response["error"]["message"]}.
            #{response}
          HEREDOC
        end
      end
    end
  end
end
