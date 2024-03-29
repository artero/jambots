# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### Unreleased

- Return OpenAi chat in stream.
- The `chat` command is now interactive, and the new `ask` command allows us to execute independent queries, just like we did before. [#30]https://github.com/artero/jambots/pull/30
- Rename 'experiments' directory to 'examples'.
- Moved The OpenAI functionality to a chat Jambots::Clients::OpenAIClient. [#12](https://github.com/artero/jambots/pull/12)
- Update application entry point to use Jambots::Bot class instead of ChatController class.
- Remove Renderers and ChatController and NewController.
- Add Yard Documentation.

### [0.2.0] - 2023-05-12

- Handle OpenAI errors [#6](https://github.com/artero/jambots/issues/6).
- Add directory for experiments and examples, and add example "Bot with option references for Ruby development" [#10](https://github.com/artero/jambots/pull/10).
- Add no_pretty renderer option to chat command [#9](https://github.com/artero/jambots/pull/9).
- Fix Readme.
- Remove unnecessary files.

### [0.1.3] - 2023-05-07

- Initial release.
