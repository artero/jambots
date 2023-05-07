require "spec_helper"

RSpec.describe Jambots::Controllers::NewController do
  describe "#create_bot" do
    let(:options) { {path: "/path/to/bots", model: "AI model", prompt: "Introduction text"} }
    let(:controller) { described_class.new(options) }

    before do
      allow(Jambots::Bot).to receive(:create)
      allow($stdout).to receive(:puts)
    end

    it "creates a new bot with the specified options" do
      expect(Jambots::Bot).to receive(:create).with("testbot", path: "/path/to/bots", model: "AI model", prompt: "Introduction text")
      controller.create_bot("testbot")
    end

    it "outputs the bot creation message" do
      expect($stdout).to receive(:puts).with("Bot 'testbot' created in '/path/to/bots/testbot'")
      controller.create_bot("testbot")
    end

    context "when options are not specified" do
      let(:options) { {} }

      it "creates a new bot with default options" do
        expect(Jambots::Bot).to receive(:create).with("testbot", path: "./.jambots", model: "gpt-3.5-turbo", prompt: nil)
        controller.create_bot("testbot")
      end
    end
  end
end
