# frozen_string_literal: true

require_relative "lib/jambots/version"

Gem::Specification.new do |spec|
  spec.name = "jambots"
  spec.version = Jambots::VERSION
  spec.authors = ["Juan Artero"]
  spec.email = ["juan.artero@marsbased.com"]

  spec.summary = "Chat bots in your terminal"
  spec.description = <<-DESCRIPTION
    Jambots is a command-line interface (CLI) tool for interacting with chatbots powered by OpenAI's GPT. It allows you to create new chatbots, manage chatbot conversations, and send messages to chatbots.
  DESCRIPTION
  spec.homepage = "https://github.com/artero/jambots"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/artero/jambots"
  spec.metadata["changelog_uri"] = "https://github.com/artero/jambots/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.executables << "jambots"

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ruby-openai", "~> 3.7"
  spec.add_dependency "thor", "~> 1.2.1"
  spec.add_dependency "tty-spinner", "~> 0.9.3"
  spec.add_dependency "pastel", "~> 0.8.0"

  spec.add_development_dependency "pry", "~> 0.13.1"
  spec.add_development_dependency "standard", "~> 1.25.3"
end
