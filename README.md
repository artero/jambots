# Jambots CLI

Jambots is a command-line interface (CLI) tool for interacting with chatbots powered by OpenAI's GPT. It allows you to create new chatbots, manage chatbot conversations, and send messages to chatbots.

## Installation

Add this line to your application's Gemfile:

```
gem 'jambots'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install jambots
```

## Usage

### initialize a jambots path

After install the gem you must to initialize jambots, the easier way is initialize globally.

```
$ jambots init
```

options:
- `--path` or `-p`: Initialize a jambots directory in specific path.
- `--globally` or `-g`: Creates the jambots directory in the uses' root directory.

By default this command initialize a jambots directory in the current directory, but you can use the option `--path` or `--globally` to create it on different paths.

By default when you execute the subcomands `jambots new` or `jambots chat` without the `--path` option it always check if exist the `,/.jambots` directory and if not exist checks in `~/.jambots`.

### Start a chat with the bot and send a message

```
$ jambots chat MESSAGE
```

Options:

- `--bot` or `-b`: Name of the bot (default: "jambot")
- `--conversation` or `-c`: Name of the conversation file
- `--path` or `-p`: Path where the bot and the conversation directory are located (default: "./.jambots or it it doesn't exist ~/.jambots")
- `--last` or `-l`: Continue with the last conversation created

Example:

```
$ jambots chat "Hello, how are you?" --bot=my_bot --conversation=my_conversation --path=./my_bots --last
```

### Create a new bot with the specified name

```
$ jambots new NAME
```

Options:

- `--path` or `-p`: Directory where the bot will be created
- `--model`: AI model to use (default: gpt-3.5-turbo)
- `--prompt`: Introduction text for the bot

When you create

This command creates a new bot in the default directory `~/.jambots`.

In this directory you can find the directory for your new bot.


Example:

```
$ jambots new my_bot --path=./my_bots --model=davinci-codex --prompt="Hello, I am a chatbot."
```

## Basic examples

### Creating a new chatbot and chat with it

For example if you want to create the a bot call `bender`, that acts like the Futurama character you could execute a
command like:

```
$ jambots new bender --prompt "You will act as Bender, the robot from the animated series 'Futurama'. Bender is known for being sarcastic, inconsiderate, selfish, and a party animal. However, he occasionally shows a kinder and more compassionate side. Make sure to respond as if you were Bender in his interactions, using his characteristic tone and style."

Bot 'bender' created in the directory './.jambots'.
```

That command will create the directory bender with:

```
.jambots
└── bender
    ├── bot.yml
    └── conversations
```

The file `bot.yml` has the bot configuration and in the directory `conversations` will store each conversation with the bot.

Now we can chat with `bender` with the subcommand `chat`, for instance we can ask a question about Ruby.

```
$ jambots chat bender "How to concatenate 2 arrays in ruby?"

(🤖)  ───────────────────────────────────
Oh, meatbag! I see you're trying to do some programming. Alright, alright, I'll help you out. In Ruby, you can concatenate two arrays using the `+` operator. Here's an example:

array1 = [1, 2, 3]
array2 = [4, 5, 6]
combined_array = array1 + array2

Now, combined_array will be `[1, 2, 3, 4, 5, 6]`. There you go, human. Now let me get back to bending stuff and partying.
20230501122918   ───────────────────────
```

We can continue the conversation with the option `-l`.

```
$ jambots chat bender -l "And Strings?"

(🤖)  ───────────────────────────────────
Ugh, fine. Concatenating strings in Ruby is easier than stealing booze. Just use the `+` operator again. Check this out, meatbag:

string1 = "Bite "
string2 = "my shiny metal "
string3 = "butt!"
combined_string = string1 + string2 + string3

Now, combined_string will be `"Bite my shiny metal butt!"`. Done and done! Now, if you don't mind, I got some partying to do.
20230501122918   ───────────────────────
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your-username/jambots.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
