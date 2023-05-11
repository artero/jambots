require "spec_helper"

RSpec.describe Jambots::Controllers::ChatController do
  describe "#chat" do
    let(:options) { {bot: "testbot", path: "/path/to/bots", no_pretty: true} }
    let(:controller) { described_class.new(options) }
    let(:conversation) { double("conversation") }
    let(:message) { double("message") }
    let(:bot) { instance_double("Jambots::Bot", conversations: conversations, load_conversation: conversation, new_conversation: conversation, message: message) }
    let(:conversations) { double("conversations", last: conversation) }

    before do
      allow(Jambots::Bot).to receive(:new).and_return(bot)
      allow(bot).to receive(:message).with("hello", conversation).and_return({content: "response"})
    end

    it "sends the query to the bot to get a response" do
      controller.chat("hello")

      expect(bot).to have_received(:message).with("hello", conversation)
    end

    context "when last conversation is specified" do
      let(:options) { {last: true} }

      it "loads the last conversation from the bot" do
        expect(bot.conversations).to receive(:last).and_return(conversation)
        expect(controller.conversation).to eq(conversation)
      end
    end

    context "when conversation is specified" do
      let(:options) { {conversation: "conversation-id"} }

      it "loads the specified conversation from the bot" do
        expect(bot).to receive(:load_conversation).with("conversation-id").and_return(conversation)
        expect(controller.conversation).to eq(conversation)
      end
    end

    context "when no conversation is specified" do
      let(:options) { {no_pretty: true} }

      it "creates a new conversation" do
        expect(bot).to receive(:load_conversation).and_return(nil)
        expect(bot).to receive(:new_conversation).and_return(conversation)
        expect(controller.conversation).to eq(conversation)
      end
    end

    context "when no_pretty is specified" do
      let(:options) { {} }

      it "uses the minimal renderer" do
        expect(controller.renderer.class).to eq(Jambots::Renderers::CliRenderer)
      end
    end

    context "when no_pretty is not specified" do
      let(:options) { {no_pretty: true} }

      it "does not use the pretty renderer" do
        expect(controller.renderer.class).to eq(Jambots::Renderers::MinimalRenderer)
      end
    end
  end
end
