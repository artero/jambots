RSpec.describe Jambots::Cli do
  let(:cli) { described_class.new }

  describe "#new" do
    let(:bot_name) { "test_bot" }
    let(:temp_dir) { "./tmp/bots" }
    let(:bot_dir) { "#{temp_dir}/#{bot_name}" }

    before do
      FileUtils.rm_rf(temp_dir)
      FileUtils.mkdir_p(temp_dir)
    end

    after do
      FileUtils.remove_entry(temp_dir)
    end

    it "creates a new bot with the specified name" do
      expect {
        Jambots::Cli.new.invoke(:new, [bot_name], {path: temp_dir})
      }.to change {
        Dir.exist?(bot_dir)
      }.from(false).to(true)
    end

    it "creates bot.yml file with default settings" do
      Jambots::Cli.new.invoke(:new, [bot_name], {path: temp_dir})

      bot_yml_path = "#{bot_dir}/bot.yml"
      expect(File.exist?(bot_yml_path)).to be_truthy
      bot_yml_content = YAML.safe_load(File.read(bot_yml_path), symbolize_names: true)
      expect(bot_yml_content).to include(
        model: Jambots::Bot::DEFAULT_MODEL,
        prompt: nil
      )
    end

    it "creates conversations directory" do
      Jambots::Cli.new.invoke(:new, [bot_name], {path: temp_dir})

      expect(Dir.exist?("#{bot_dir}/conversations")).to be_truthy
    end

    it "returns a success message" do
      expect {
        Jambots::Cli.new.invoke(:new, [bot_name], {path: temp_dir})
      }.to output(/Bot '#{bot_name}' created in '#{bot_dir}'/).to_stdout
    end
  end
end
