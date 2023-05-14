# frozen_string_literal: true

class AbstractChatClient
  def initialize
    raise NotImplementedError, "initialize must be implemented in the derived class"
  end

  def chat
    raise NotImplementedError, "chat method must be implemented in the derived class"
  end
end
