# Jambots CLI

:warning: **Important notice:** This gem is in an early stage of development. Changes in commands or class interfaces may be introduced in future versions. Use it at your own risk and make sure to stay up-to-date with updates. :warning:

Jambots is a command-line interface (CLI) tool for interacting with chatbots powered by OpenAI's GPT. It lets you create new chatbots, manage conversations, and send messages to chatbots.

## Installation

Add this line to your application's Gemfile:

```
gem 'jambots'
```

Then execute:

```
$ bundle install
```

Or install it yourself:

```
$ gem install jambots
```

You need to create the environment variable OPENAI_API_KEY with the value of your OpenAI API Key.

For instance, if you use bash:

```
echo 'export OPENAI_API_KEY="your_openai_api_key"' >> ~/.bashrc
source ~/.bashrc
```

## Usage

### Initialize a Jambots path

After installing the gem, you need to initialize Jambots:

```
$ jambots init
```

Options:
-  `--path` or `-p`: Initialize a Jambots directory in a specific path.
-  `--globally` or `-g`: Create the Jambots directory in the user's root directory.

This command generates a Jambots directory with the default bot directory named "jambot."

By default, this command initializes a Jambots directory in the current directory. However, you can use the `--path` or `--globally` options to create it at different paths.

#### The Jambot path

When you execute the subcommands `jambots new` or `jambots chat` without the `--path` option, Jambots will check for the existence of the `./.jambots` directory, and if not found, it will check for `~/.jambots`.

### Start a chat and send a message

```
$ jambots chat MESSAGE
```

Options:
-  `--bot` or `-b`: Name of the bot (default: "jambot")
-  `--conversation` or `-c`: Name of the conversation key
-  `--path` or `-p`: Path where the bot and the conversation directory are located (default: "./.jambots" or, if it doesn't exist, `~/.jambots`)
-  `--last` or `-l`: Continue the last conversation created
-  `--no_pretty` or `-n`: Disable pretty formatting for the output

#### Conversation example

```
$ jambots chat "Hello, how are you?"
```

This command starts a new conversation with the default bot. As a response, you will get an output like the following, for instance:

```
(🤖)  ───────────────────────────────────
Hello! As an AI, I don't have personal feelings, but I'm here to help you with any questions or information you need. How can I assist you today?
20230506205026   ───────────────────────
```

This conversation will continue until you write `:exit`.

Apart from the bot's response, you'll get a conversation key, for example, 20230506205026.

To continue the last conversation, use the `-l` (last) option. To continue an older one, use the `-c` (continue) option with the conversation key.

For reference, all conversations are saved in the `./jambots/jambot/conversations/` directory. Each conversation has its own YAML file, e.g. `20230506205026.yml`.

To ask a single question, run the `ask` command with the same options.

### Create a new bot with a specified name

```
$ jambots new NAME
```

Options:
-  `--path` or `-p`: Directory where the bot will be created
-  `--model`: AI model to use (default: gpt-3.5-turbo)
-  `--prompt`: Introduction text for the bot

This command creates a new bot in the default directory `~/.jambots`.

In this directory, you will find the directory for your new bot.

#### New bot example

```
$ jambots new my_bot --path=./my_bots --model=gpt-4
--prompt="You will help me with development in Ruby"
```

To start a new conversation with this `new_bot`, use the `jambots chat` or `jambots ask` command with the appropriate options.

## Basic examples: Creating a new chatbot and chatting with it

For example, if you want to create a bot called bender that acts like the Futurama character, you could execute a command like:

```
$ jambots new bender --prompt "You will act as Bender, the robot from the animated series 'Futurama'. Bender is known for being sarcastic, inconsiderate, selfish, and a party animal. However, he occasionally shows a kinder and more compassionate side. Make sure to respond as if you were Bender in his interactions, using his characteristic tone and style."

Bot 'bender' created  './.jambots/bender'
```

This command creates the bender bot, and its directory has the following structure:

```
.jambots
└── bender
    ├── bot.yml
    └── conversations
```

The file `bot.yml` contains the bot configuration, and the conversations directory stores each conversation with the bot.

Now you can chat with `bender` using the `chat` subcommand. For instance, you can ask a question about Ruby:

```
$ jambots ask -b bender "How to concatenate 2 arrays in Ruby?"

(🤖)  ───────────────────────────────────
Oh, meatbag! I see you're trying to do some programming. Alright, alright, I'll help you out. In Ruby, you can concatenate two arrays using the `+` operator. Here's an example:

array1 = [1, 2, 3]
array2 = [4, 5, 6]
combined_array = array1 + array2

Now, combined_array will be `[1, 2, 3, 4, 5, 6]`. There you go, human. Now let me get back to bending stuff and partying.
20230501122918   ───────────────────────
```

You can continue the conversation with the option `-l` (last).

```
$ jambots ask -b bender -l "And Strings?"

(🤖)  ───────────────────────────────────
Ugh, fine. Concatenating strings in Ruby is easier than stealing booze. Just use the `+` operator again. Check this out, meatbag:

string1 = "Bite "
string2 = "my shiny metal "
string3 = "butt!"
combined_string = string1 + string2 + string3

Now, combined_string will be `"Bite my shiny metal butt!"`. Done and done! Now, if you don't mind, I got some partying to do.
20230501122918   ───────────────────────
```

## Experiments

In this directory, you can find examples of how to use Jambots and experiments that we consider attractive.

-  [Bot with option references for Ruby development](experiments/bot_with_option_references)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/artero/jambots.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
