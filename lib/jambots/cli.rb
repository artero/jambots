module Jambots
  class Cli



    private

    def render(text, options = {})
    end

    def pastel
      @pastel ||= Pastel.new
    end

    def spinner
      @spinner ||= TTY::Spinner.new(
        "( #{face} )  [#{pastel.green(":spinner")}] ",
        format: :pulse_2,
        clear: true
      )
    end
  end
end
