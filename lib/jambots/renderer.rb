# frozen_string_literal: true

require "tty-spinner"
require "pastel"

module Jambots
  class Renderer

    def spinner
      @spinner ||= TTY::Spinner.new(
        "(🤖)  [#{pastel.green(":spinner")}] ",
        format: :pulse_2,
        clear: true
      )
    end

    def pastel
      @pastel ||= Pastel.new
    end

    def render(message)
      print_line(role_header(message[:role]))
      puts pastel.magenta(message[:content])
    end

    private

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

    def print_line(text = "", max_length: 40, character: "─")
      text_length = text.to_s.length
      line = (text_length < max_length) ? character * (max_length - text_length) : ""

      puts "#{text}#{line}"
    end
  end
end
