module Jambots
  module Controllers
    class InitController
      def initialize(options)
        @options = options
      end

      def init_jambots_path
        path = if @options[:globally]
                 File.expand_path('~/.jambots')
               elsif @options[:path]
                 File.expand_path(@options[:path])
               else
                 './.jambots'
               end

        FileUtils.mkdir_p(path)
        puts "Jambots directory initialized at '#{path}'."

        # Create default bot
        Jambots::Bot.create("jambot", path: path)
      end
    end
  end
end
