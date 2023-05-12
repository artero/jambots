# frozen_string_literal: true

module Jambots::Renderers
  class MinimalRenderer
    def render(conversation, &block)
      message = block.call
      puts message[:content]
    rescue Jambots::ChatClientError => e
      warn "ERROR: #{e.message}"
      exit(1)
    end
  end
end
