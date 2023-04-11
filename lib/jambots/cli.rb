require "thor"
require "tty-spinner"
require "pastel"

module Jambots
  class Cli < Thor
    attr_reader :bot

    option :bot, type: :string, aliases: "-b", banner: "<bot file>"
    desc "bot NAME", "Greets NAME"
    def chat(query)
      load_robot(options)

      spinner.auto_spin
      message = bot.message(query)
      spinner.success

      render(message)
      puts bot.history_file_path
    rescue OpenAIMessageError => e
      puts e
    end

    desc "history", "history hello"
    def history
      load_robot(options)
      bot.messages.each do |message|
        render(message)
      end
    end

    option :boot, type: :string, aliases: "-b", banner: "<boot>"
    option :messages, type: :numeric, aliases: "-l", banner: "<line>"
    desc "clean", "clean hello"
    def clean
      load_robot(options)
      bot.clean_history(options[:messages])
    end

    private

    def load_robot(options)
      default_options = {
        openai_apy_key: ENV["OPENAI_API_KEY"],
        name: "Ron",
        user_name: "Juan",
        face: "🤖",
        record_history: true,
        model: "gpt-3.5-turbo",
        prompt: "",
        log: false
      }
      bot_options = options[:bot] && File.exist?(options[:bot]) ? YAML.safe_load(File.read(options[:bot]), symbolize_names: true) : {}
      config = default_options.merge(bot_options)

      @bot = Jambots::Bot.new(config)
    end

    def render(message, options = {})
      if options[:raw]
        puts message
      else
        print_line(role_header(message[:role]))
        puts pastel.magenta(message[:content])
      end
    end

    def role_header(rol)
      case rol.to_sym
      when :system
        "(🗄)  "
      when :assistant
        "(🤖)  "
      when :user
        "(👤)  "
      else
        "(⁇)   "
      end
    end

    def spinner
      @spinner ||= TTY::Spinner.new(
        "( #{bot.face} )  [#{pastel.green(":spinner")}] ",
        format: :pulse_2,
        clear: true
      )
    end

    def print_line(text = "", max_length: 40, character: "─")
      text_length = text.to_s.length
      line = (text_length < max_length) ? character * (max_length - text_length) : ""

      puts "#{text}#{line}"
    end

    def pastel
      @pastel ||= Pastel.new
    end
  end
end
