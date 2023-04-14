# frozen_string_literal: true

require "spec_helper"

module Jambots
  RSpec.describe Bot do
    let(:bot) do
      FileUtils.rm_rf("#{default_bots_dir}/#{bot_name}")

      Bot.create(
        bot_name,
        directory: custom_bots_dir
      )
    end

    let(:bot_name) { "test_bot" }
    let(:custom_bots_dir) { "custom_bots" }
    let(:default_bots_dir) { "#{ENV["HOME"]}/.jambots" }

    before do
      FileUtils.rm_rf("#{default_bots_dir}/#{bot_name}")
      FileUtils.rm_rf("#{custom_bots_dir}/#{bot_name}")
    end

    after do
      # Clean up the created directories after each test
      FileUtils.rm_rf("#{default_bots_dir}/#{bot_name}")
      FileUtils.rm_rf("#{custom_bots_dir}/#{bot_name}")
    end

    describe ".create" do
      let(:default_bots_dir) { "#{ENV["HOME"]}/.jambots" }
      let(:name) { "test_bot" }
      let(:model) { "gpt-4" }
      let(:prompt) { "Hello, how can I help you?" }
      let(:custom_bots_dir) { "tmp/custom_bots" }

      after do
        FileUtils.rm_rf("#{default_bots_dir}/#{name}")
        FileUtils.rm_rf("#{custom_bots_dir}/#{name}")
      end

      it "creates a bot with custom options" do
        bot = described_class.create(name, directory: custom_bots_dir, model: model, prompt: prompt)

        bot_dir = bot.bot_dir
        expect(bot_dir).to eq("#{custom_bots_dir}/#{name}")
        expect(Dir.exist?(bot_dir)).to be(true)

        expect(Dir.exist?("#{bot_dir}/conversations")).to be(true)
        expect(File.exist?("#{bot_dir}/bot.yml")).to be(true)

        bot_yml_content = YAML.safe_load(File.read("#{bot_dir}/bot.yml"), permitted_classes: [Symbol], symbolize_names: true)
        expect(bot_yml_content[:model]).to eq(model)
        expect(bot_yml_content[:prompt]).to eq(prompt)
      end
    end

    describe "#initialize" do
      context "when the bot doesn't exist" do
        it "raises an error" do
          expect {
            Bot.new(
              "non_existent_bot",
              openai_api_key: "your_openai_api_key_here"
            )
          }.to raise_error(RuntimeError, "Bot non_existent_bot doesn't exist.")
        end
      end

      context "when the bot exists" do
        let(:existing_bot_name) { "existing_bot" }
        let(:existing_bot_dir) { "#{default_bots_dir}/#{existing_bot_name}" }

        before do
          # Create a bot using the .create method
          Bot.create(existing_bot_name)
        end

        after do
          # Clean up the created directories after the test
          FileUtils.rm_rf(existing_bot_dir)
        end

        it "loads the bot without raising an error" do
          expect {
            Bot.new(
              existing_bot_name,
              openai_api_key: "your_openai_api_key_here"
            )
          }.not_to raise_error
        end
      end
    end

    describe "#message" do
      let(:client) { double(:client) }
      let(:text) { "Hello, how are you?" }
      let(:response) do
        {
          "choices" => [
            {
              "message" => {
                "role" => "assistant",
                "content" => "I'm doing well, thank you! How can I help you today?"
              }
            }
          ]
        }
      end

      before do
        allow(OpenAI::Client).to receive(:new).and_return(client)
        allow(client).to receive(:chat).and_return(response)
      end

      it "sends a message and receives a response" do
        message = bot.message(text)

        expect(client).to have_received(:chat)
        expect(message[:role]).to eq("assistant")
        expect(message[:content]).to eq("I'm doing well, thank you! How can I help you today?")
      end
    end

    describe "#conversations" do
      it "returns a list of conversations" do
        conversations = bot.conversations

        expect(conversations).to all(be_a(Conversation))
      end
    end
  end
end
