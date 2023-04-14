# frozen_string_literal: true

require "spec_helper"

module Jambots
  RSpec.describe Conversation do
    let(:conversation) { Conversation.new("tmp/test_conversation.yml") }

    after(:each) do
      File.delete("tmp/test_conversation.yml") if File.exist?("tmp/test_conversation.yml")
    end

    it "adds a message to the conversation" do
      conversation.add_message("user", "Hello, bot!")
      expect(conversation.messages.last[:role]).to eq("user")
      expect(conversation.messages.last[:content]).to eq("Hello, bot!")
    end

    it "saves the conversation to a file" do
      conversation.add_message("user", "Hello, bot!")
      conversation.save

      expect(File.exist?("tmp/test_conversation.yml")).to be_truthy
    end

    it "loads messages from a file" do
      conversation.add_message("user", "Hello, bot!")
      conversation.save

      loaded_conversation = Conversation.new("tmp/test_conversation.yml")
      expect(loaded_conversation.messages.last[:role]).to eq("user")
      expect(loaded_conversation.messages.last[:content]).to eq("Hello, bot!")
    end

    it "deletes the conversation file" do
      conversation.add_message("user", "Hello, bot!")
      conversation.save
      conversation.delete

      expect(File.exist?("tmp/test_conversation.yml")).to be_falsy
    end
  end
end
