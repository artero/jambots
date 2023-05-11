require "spec_helper"

RSpec.describe Jambots::Controllers::ChatController do
  let(:options) { {bot: "test_bot", path: "./spec/fixtures/bots"} }
  let(:controller) { described_class.new(options) }

  describe "#initialize" do
    context "when last conversation is specified" do
      let(:options) { {bot: "test_bot", path: "./spec/fixtures/bots", last: true} }

      it "loads the last conversation from the bot" do
        # last conversation in ./spec/fixtures/bots/test_bot/conversations is 2.yml
        expect(controller.conversation.key).to eq("2")
      end
    end

    context "when conversation is specified" do
      let(:options) { {bot: "test_bot", path: "./spec/fixtures/bots", conversation: "1"} }

      it "loads the specified conversation from the bot" do
        expect(controller.conversation.key).to eq("1")
      end
    end

    context "when no conversation is specified" do
      let(:options) { {bot: "test_bot", path: "./spec/fixtures/bots"} }
      let(:conversation) { double("Jambots::Conversation") }

      it "creates a new conversation" do
        allow_any_instance_of(Jambots::Bot).to receive(:new_conversation).and_return(conversation)

        expect(controller.conversation).to eq(conversation)
      end
    end

    context "when no_pretty is specified" do
      it "uses the minimal renderer" do
        expect(controller.renderer.class).to eq(Jambots::Renderers::CliRenderer)
      end
    end

    context "when no_pretty is not specified" do
      let(:options) { {bot: "test_bot", path: "./spec/fixtures/bots", no_pretty: true} }

      it "does not use the pretty renderer" do
        expect(controller.renderer.class).to eq(Jambots::Renderers::MinimalRenderer)
      end
    end
  end

  describe "#chat" do
    before do
      allow(controller.bot).to receive(:message).with("hello", controller.conversation).and_return({content: "response"})

      allow(controller.renderer).to receive(:render) do |&block|
        block.call
      end
    end

    it "sends the query to the bot to get a response" do
      controller.chat("hello")
      expect(controller.bot).to have_received(:message).with("hello", controller.conversation)
      expect(controller.renderer).to have_received(:render).with(controller.conversation)
    end
  end
end
