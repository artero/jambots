require "date"
# require "openai"

RSpec.describe Jambots::Bot do
  let(:bot) {
    Jambots::Bot.new(
      name: "TestBot",
      user_name: "Jam",
      face: ":)",
      record_history: false,
      model: "fake_model"
    )
  }

  describe "#initialize" do
    it "sets the correct attributes" do
      expect(bot.name).to eq "TestBot"
      expect(bot.user_name).to eq "Jam"
      expect(bot.face).to eq ":)"
      expect(bot.model).to eq "fake_model"
      expect(bot.options[:record_history]).to eq false
    end
  end

  describe "#message" do
    it "returns a response with the correct role" do
      allow(bot).to receive(:client).and_return(double("OpenAI::Client", chat: {"choices" => [{"message" => {"role" => "TestBot", "content" => "Hello, Jam!"}}]}))
      response = bot.message("Hello, TestBot!")
      expect(response[-1]["role"]).to eq "TestBot"
    end
  end

  describe "#record_history?" do
    it "returns the correct value" do
      expect(bot.send(:record_history?)).to eq false
    end
  end

  describe "#build_messages" do
    it "builds messages with the correct role" do
      messages = bot.send(:build_messages)
      expect(messages[0][:role]).to eq "system"
    end
  end

  describe "#clean_history" do
    it "deletes the history file if it exists" do
      allow(File).to receive(:exist?).and_return(true)
      expect(File).to receive(:delete).with(bot.history_file_path)
      bot.clean_history
    end

    it "does not attempt to delete the history file if it does not exist" do
      allow(File).to receive(:exist?).and_return(false)
      expect(File).not_to receive(:delete)
      bot.clean_history
    end
  end
end
