require "thor"

module Jambots
  class Cli < Thor
    DEFAULT_BOT = "jambot"

    desc "chat MESSAGE", "Inicia un chat con el bot y envía un mensaje"
    option :bot, aliases: "-b", desc: "Nombre del bot"
    option :conversation, desc: "Nombre del fichero de la conversación"
    option :path, desc: "Ruta donde se encuentra el bot y el directorio de conversaciones"
    option :continue, type: :boolean, aliases: "-c", desc: "Continuar con la última conversación creada"
    def chat(query)
      bot = Bot.new(
        options[:bot] || DEFAULT_BOT,
        path: options[:path] || Jambots::Bot::DEFAULT_BOTS_DIR
      )

      continue = options[:continue]
      previous_conversation = continue ? bot.conversations.last : bot.load_conversation(options[:conversation])
      conversation = previous_conversation || bot.new_conversation

      renderer.spinner.auto_spin
      message = bot.message(query, conversation)
      renderer.spinner.success
      renderer.render(message, conversation)
    end

    desc "new NAME", "Crea un nuevo bot con el nombre especificado"
    option :directory, desc: "Directorio donde se creará el bot"
    option :model, desc: "Modelo de IA a utilizar"
    option :prompt, desc: "Texto de introducción para el bot"
    def new(name)
      directory = options[:directory] || Jambots::Bot::DEFAULT_BOTS_DIR
      model = options[:model] || Jambots::Bot::DEFAULT_MODEL
      prompt = options[:prompt]

      Jambots::Bot.create(name, directory: directory, model: model, prompt: prompt)
      puts "Bot '#{name}' creado en el directorio '#{directory}'."
    end

    private

    def renderer
      @renderer ||= Renderer.new
    end
  end
end
