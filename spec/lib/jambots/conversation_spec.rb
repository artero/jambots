# spec/jambots/conversation_spec.rb
require "spec_helper"

RSpec.describe Jambots::Conversation do
  let(:conversation_file_path) { "./spec/fixtures/test_bot/conversations/1.yml" }
  let(:conversation) { described_class.new(conversation_file_path) }

  describe "#initialize" do
    it "initializes a conversation with the correct file path" do
      expect(conversation.file_path).to eq(conversation_file_path)
    end

    it "loads messages from the file" do
      expect(conversation.messages).not_to be_empty
    end
  end

  describe "#add_message" do
    it "adds a message to the messages array" do
      expect {
        conversation.add_message("user", "Hello!")
      }.to change { conversation.messages.count }.by(1)
    end
  end

  describe "#save" do
    let(:new_conversation_file_path) { "./spec/fixtures/conversations/new_conversation.yml" }
    let(:new_conversation) { described_class.new(new_conversation_file_path) }

    after do
      File.delete(new_conversation_file_path) if File.exist?(new_conversation_file_path)
    end

    it "saves the messages to the file" do
      new_conversation.add_message("user", "Hello!")
      new_conversation.save
      saved_content = File.read(new_conversation_file_path)
      expect(saved_content).to include("Hello!")
    end
  end

  describe "#load_messages" do
    context "when the file exists" do
      it "loads messages from the file" do
        messages = conversation.load_messages
        expect(messages).not_to be_empty
      end
    end

    context "when the file does not exist" do
      it "returns an empty array" do
        non_existent_conversation = described_class.new("./spec/fixtures/conversations/non_existent.yml")
        messages = non_existent_conversation.load_messages
        expect(messages).to be_empty
      end
    end
  end

  describe "#delete" do
    let(:deletable_conversation_file_path) { "./spec/fixtures/conversations/deletable_conversation.yml" }
    let(:deletable_conversation) { described_class.new(deletable_conversation_file_path) }

    before do
      FileUtils.touch(deletable_conversation_file_path)
    end

    it "deletes the conversation file" do
      expect {
        deletable_conversation.delete
      }.to change { File.exist?(deletable_conversation_file_path) }.from(true).to(false)
    end
  end
end
