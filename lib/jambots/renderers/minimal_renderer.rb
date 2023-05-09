# frozen_string_literal: true

require "tty-spinner"
require "pastel"

module Jambots::Renderers
  class MinimalRenderer
    def render(conversation, &block)
      message = block.call
      puts message[:content]
    end
  end
end
