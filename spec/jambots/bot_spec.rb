# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jambots::Bot do
  let(:bot_name) { "test_bot" }
  let(:bot_path) { "./spec/fixtures/bots" }
  let(:bot) { described_class.new(bot_name, path: bot_path.to_s) }

  describe ".create" do
    before do
      FileUtils.rm_rf(new_bot_path)
      FileUtils.mkdir_p(new_bot_path)
    end

    after do
      FileUtils.rm_rf(new_bot_path)
    end

    let(:new_bot_name) { "new_bot" }
    let(:new_bot_path) { "./tmp/bots" }
    let(:bot_path) { "#{new_bot_path}/#{new_bot_name}" }

    it "creates a new bot" do
      expect do
        described_class.create(new_bot_name, path: new_bot_path)
      end.to change { Dir.exist?(bot_path) }.from(false).to(true)
    end

    it "creates the bot.yml configuration file" do
      described_class.create(new_bot_name, path: new_bot_path)
      expect(File.exist?("#{bot_path}/bot.yml")).to eq true
    end

    it "creates the conversations directory" do
      described_class.create(new_bot_name, path: new_bot_path)
      expect(Dir.exist?("#{bot_path}/conversations")).to eq true
    end
  end

  describe ".find_path" do
    context "when path is provided" do
      it "returns the provided path" do
        path = "/custom/path"
        expect(Jambots::Bot.find_path(path)).to eq(path)
      end
    end

    context "when path is not provided" do
      it "returns the default local bots directory if it exists" do
        allow(Dir).to receive(:exist?).with(Jambots::Bot::DEFAULT_LOCAL_BOTS_DIR).and_return(true)
        expect(Jambots::Bot.find_path).to eq(Jambots::Bot::DEFAULT_LOCAL_BOTS_DIR)
      end

      it "returns the default global bots directory if the local directory does not exist" do
        allow(Dir).to receive(:exist?).with(Jambots::Bot::DEFAULT_LOCAL_BOTS_DIR).and_return(false)
        expect(Jambots::Bot.find_path).to eq(Jambots::Bot::DEFAULT_GLOBAL_BOTS_DIR)
      end
    end
  end

  describe "#find_path" do
    context "when path is provided" do
      it "returns the provided path" do
        path = "/custom/path"
        expect(bot.find_path(path)).to eq(path)
      end
    end

    context "when path is not provided" do
      it "returns the default local bots directory if it exists" do
        allow(Dir).to receive(:exist?).with(Jambots::Bot::DEFAULT_LOCAL_BOTS_DIR).and_return(true)
        expect(bot.find_path).to eq(Jambots::Bot::DEFAULT_LOCAL_BOTS_DIR)
      end

      it "returns the default global bots directory if the local directory does not exist" do
        allow(Dir).to receive(:exist?).with(Jambots::Bot::DEFAULT_LOCAL_BOTS_DIR).and_return(false)
        expect(bot.find_path).to eq(Jambots::Bot::DEFAULT_GLOBAL_BOTS_DIR)
      end
    end
  end

  describe "#initialize" do
    it "initializes a bot with the correct name" do
      expect(bot.name).to eq(bot_name)
    end

    it "loads options from the bot.yml configuration file" do
      expect(bot.model).to eq(Jambots::Bot::DEFAULT_MODEL)
      expect(bot.prompt).to eq("Hello! I am your test bot.")
    end
  end

  describe "#message" do
    let(:conversation_path) { "./tmp/conversation.yml" }
    let(:conversation) do
      conversation = Jambots::Conversation.new(conversation_path)
      conversation.add_message("system", "Hello")
      conversation
    end
    let(:user_message) { "Hello, bot!" }

    before do
      File.delete(conversation_path) if File.exist?(conversation_path)

      allow(bot.client).to receive(:chat).and_return(
        "choices" => [
          {
            "role" => "assistant",
            "message" => {
              "content" => "Hello, user!"
            }
          }
        ]
      )
    end

    after do
      File.delete(conversation_path) if File.exist?(conversation_path)
    end

    it "sends a message to the bot and receives a response" do
      response_message = bot.message(user_message, conversation)
      expect(response_message[:role]).to eq("assistant")
      expect(response_message[:content]).to eq("Hello, user!")
    end

    it "adds the message to the conversation" do
      expect {
        bot.message(user_message, conversation)
      }.to change { conversation.messages.count }.by(2)
    end
  end

  describe "#conversations" do
    it "returns an array of Conversation instances" do
      conversations = bot.conversations
      expect(conversations).to all(be_a(Jambots::Conversation))
    end
  end

  describe "#new_conversation" do
    it "creates a new Conversation instance" do
      new_conversation = bot.new_conversation
      expect(new_conversation).to be_a(Jambots::Conversation)
    end
  end

  describe "#load_conversation" do
    let(:conversation_name) { "1" }

    context "when the conversation exists" do
      it "loads the conversation" do
        conversation = bot.load_conversation(conversation_name)
        expect(conversation).to be_a(Jambots::Conversation)
      end
    end

    context "when the conversation does not exist" do
      it "returns nil" do
        conversation = bot.load_conversation("nonexistent_conversation")
        expect(conversation).to be_nil
      end
    end
  end
end
