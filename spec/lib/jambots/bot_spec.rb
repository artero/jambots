# spec/bot_spec.rb
require "spec_helper"

module Jambots
  RSpec.describe Bot do
    let(:bot) do
      Bot.new(
        openai_apy_key: "your_openai_api_key_here",
        bot: "jambot",
        bots_dir: "tmp"
      )
    end

    let(:bot_name) { "test_bot" }
    let(:custom_bots_dir) { "custom_bots" }
    let(:default_bots_dir) { "#{ENV["HOME"]}/.jambots" }

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

      # it "creates a bot with default options" do
      #   bot_dir = described_class.create(name: name)

      #   expect(bot_dir).to eq("#{default_bots_dir}/#{name}")
      #   expect(Dir.exist?(bot_dir)).to be(true)
      #   expect(Dir.exist?("#{bot_dir}/conversations")).to be(true)
      #   expect(File.exist?("#{bot_dir}/bot.yml")).to be(true)

      #   bot_yml_content = YAML.safe_load(File.read("#{bot_dir}/bot.yml"), permitted_classes: [Symbol], symbolize_names: true)
      #   expect(bot_yml_content[:model]).to eq(model)
      #   expect(bot_yml_content[:prompt]).to eq(prompt)
      # end

      it "creates a bot with custom options" do
        bot_dir = described_class.create(name: name, directory: custom_bots_dir, model: model, prompt: prompt)

        expect(bot_dir).to eq("#{custom_bots_dir}/#{name}")
        expect(Dir.exist?(bot_dir)).to be(true)
        expect(Dir.exist?("#{bot_dir}/conversations")).to be(true)
        expect(File.exist?("#{bot_dir}/bot.yml")).to be(true)

        bot_yml_content = YAML.safe_load(File.read("#{bot_dir}/bot.yml"), permitted_classes: [Symbol], symbolize_names: true)
        expect(bot_yml_content[:model]).to eq(model)
        expect(bot_yml_content[:prompt]).to eq(prompt)
      end
    end

    # it "creates a new conversation" do
    #   conversation = bot.new_conversation
    #   expect(conversation).to be_instance_of(Conversation)
    # end

    # it "lists all conversations" do
    #   conversations = bot.list_conversations
    #   expect(conversations).not_to be_empty
    # end

    # it "deletes a conversation" do
    #   conversation = bot.new_conversation
    #   file_name = conversation.file_name
    #   bot.delete_conversation(file_name)

    #   expect(bot.list_conversations).not_to include(file_name)
    # end
  end
end
