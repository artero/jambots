# frozen_string_literal: true

module Jambots
  module Controllers
    class NewController
      def initialize(options)
        @options = options
      end

      def create_bot(name)
        directory = @options[:directory] || Jambots::Bot::DEFAULT_BOTS_DIR
        model = @options[:model] || Jambots::Bot::DEFAULT_MODEL
        prompt = @options[:prompt]

        Jambots::Bot.create(name, directory: directory, model: model, prompt: prompt)
        puts "Bot '#{name}' created in the directory '#{directory}'."
      end
    end
  end
end
