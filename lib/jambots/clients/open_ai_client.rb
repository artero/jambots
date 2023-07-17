# frozen_string_literal: true

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

      def chat(args = {}, &block)
        response = chat_stream(args, &block)

        # Currently the OpenAI API Gem returns an empty response when the chat has some errors,
        # so we need to check if the response is empty and call the chat method without stream to handle the error.
        if response == ""
          chat_without_stream(args, &block)
        end
      end

      def chat_stream(args = {}, &block)
        if args[:messages].empty?
          raise ArgumentError, "messages must not be empty"
        end

        chat_params = {
          model: args[:model] || "gpt-3.5-turbo",
          messages: args[:messages],
          temperature: args[:temperature] || 0.7,
          stream: proc { |chunk, _bytesize | process_chunk(chunk, &block) }
        }

        @provider_client.chat(parameters: chat_params)
      end

      def chat_without_stream(args = {}, &block)
        if args[:messages].empty?
          raise ArgumentError, "messages must not be empty"
        end

        chat_params = {
          model: args[:model] || "gpt-3.5-turbo",
          messages: args[:messages],
          temperature: args[:temperature] || 0.7
        }

        response = @provider_client.chat(parameters: chat_params)

        if response["error"]
          raise ChatClientError, handle_error(response)
        end

        output = response.dig("choices", 0, "message", "content")

        if output.nil?
          raise(ChatClientError, "OpenAI response does not contain a message")
        end

        block.call(output)
      end

      private

      def process_chunk(chunk, &block)
        part = chunk.dig("choices", 0, "delta", "content")
        block.call(part)
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
