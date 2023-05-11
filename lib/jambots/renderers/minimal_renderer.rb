# frozen_string_literal: true

module Jambots::Renderers
  class MinimalRenderer
    def render(conversation, &block)
      message = block.call
      puts message[:content]
    end
  end
end
