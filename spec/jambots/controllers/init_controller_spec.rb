RSpec.describe Jambots::Controllers::InitController do
  let(:options) { {} }
  subject(:init_controller) { described_class.new(options) }

  xdescribe "#init_jambots_path" do
    let(:path) { "./.jambots" }
    let(:default_bot) { Jambots::Cli::DEFAULT_BOT }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(init_controller).to receive(:puts)
      allow_any_instance_of(Jambots::Controllers::NewController).to receive(:create_bot)
    end

    it "creates Jambots directory" do
      expect(FileUtils).to receive(:mkdir_p).with(path)
      expect(init_controller).to receive(:puts).with("Jambots directory initialized at '#{path}'")

      init_controller.init_jambots_path
    end

    it "creates default bot" do
      expect_any_instance_of(Jambots::Controllers::NewController).to receive(:create_bot).with(default_bot)

      init_controller.init_jambots_path
    end

    context "with options[:globally] set to true" do
      let(:options) { {globally: true} }
      let(:global_path) { File.expand_path("~/.jambots") }

      it "creates Jambots directory globally" do
        expect(FileUtils).to receive(:mkdir_p).with(global_path)
        expect(init_controller).to receive(:puts).with("Jambots directory initialized at '#{global_path}'")

        init_controller.init_jambots_path
      end
    end

    context "with options[:path] set" do
      let(:custom_path) { "/custom/path" }
      let(:options) { {path: custom_path} }
      let(:expanded_custom_path) { File.expand_path(custom_path) }

      it "creates Jambots directory at custom path" do
        expect(FileUtils).to receive(:mkdir_p).with(expanded_custom_path)
        expect(init_controller).to receive(:puts).with("Jambots directory initialized at '#{expanded_custom_path}'")

        init_controller.init_jambots_path
      end
    end
  end
end
