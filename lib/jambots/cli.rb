require "thor"
require "tty-spinner"
require "pastel"

module Jambots
  class Cli < Thor
    attr_reader :bot

    option :boot, type: :string, aliases: "-b", banner: "<boot>"
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

    option :boot, type: :string, aliases: "-b", banner: "<boot>"
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

    # Move to Jambots::Bot
    def load_robot(options)
      @bot = Jambots::Bot.new(
        openai_apy_key: ENV["OPENAI_API_KEY"],
        name: "Ron",
        user_name: "Juan",
        face: "🤖",
        record_history: true,
        model: "gpt-3.5-turbo",
        prompt: "Me ayudarás con programación en general y de Ruby en particular. Darás respuestas cortas y concisas de una frase.",
        log: false
      )
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
