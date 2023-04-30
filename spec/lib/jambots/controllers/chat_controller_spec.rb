# spec/jambots/conversation_spec.rb
require "spec_helper"

RSpec.describe Jambots::Controllers::ChatController do
  describe "#chat" do
    let(:options) { { bot: "testbot", path: "/path/to/bots" } }
    let(:controller) { described_class.new(options) }
    let(:conversation) { double("conversation") }
    let(:message) { double("message") }
    let(:renderer) { double("renderer", spinner: spinner, render: nil) }
    let(:spinner) { double("spinner", auto_spin: nil, success: nil) }
    let(:bot) { instance_double("Jambots::Bot", conversations: conversations, load_conversation: conversation, new_conversation: conversation, message: message) }
    let(:conversations) { double("conversations", last: conversation) }

    before do
      allow(Jambots::Bot).to receive(:new).and_return(bot)
      allow(Jambots::Renderer).to receive(:new).and_return(renderer)
    end

    it "sends the query to the bot to get a response" do
      expect(bot).to receive(:message).with("hello", conversation).and_return(message)
      controller.chat("hello")
    end

    it "renders the message with the conversation using the renderer" do
      expect(renderer).to receive(:render).with(message, conversation)
      controller.chat("hello")
    end

    context "when last conversation is specified" do
      let(:options) { { last: true } }

      it "loads the last conversation from the bot" do
        expect(bot.conversations).to receive(:last).and_return(conversation)
        controller.chat("hello")
      end
    end

    context "when conversation is specified" do
      let(:options) { { conversation: "conversation-id" } }

      it "loads the specified conversation from the bot" do
        expect(bot).to receive(:load_conversation).with("conversation-id").and_return(conversation)
        controller.chat("hello")
      end
    end

    context "when no conversation is specified" do
      let(:options) { {} }

      it "creates a new conversation" do
        expect(bot).to receive(:load_conversation).and_return(nil)
        expect(bot).to receive(:new_conversation).and_return(conversation)
        controller.chat("hello")
      end
    end
  end
end
