# DISCLAIMER
This Gem is a just slight modification of the [Slackistrano Gem](https://github.com/phallstrom/slackistrano) of [phallstrom](https://github.com/phallstrom).
I just slightly modified one class to send messages to Telegram instead of Slack.

# Telistrano
Send notifications to [Telegram](https://telegram.org/) about [Capistrano](http://www.capistranorb.com) deployments.

## Requirements

- Capistrano >= 3.8.1
- Ruby >= 2.0
- A Telegram account

## Installation

1. Add this line to your application's Gemfile:

   ```ruby
   gem 'telistrano', git: 'git@github.com:HappyKadaver/telistrano.git'
   ```

2. Execute:

   ```
   $ bundle
   ```

3. Require the library in your application's Capfile:

   ```ruby
   require 'telistrano/capistrano'
   ```

## Configuration

You have two options to notify a channel in Slack when you deploy:

1. Using *Incoming WebHooks* integration, offering more options but requires
   one of the five free integrations. This option provides more messaging
   flexibility.
2. Using *Slackbot*, which will not use one of the five free integrations.

### Configuration
Add the following to your deploy.rb :
```
set :telistrano, {
    chat_ids: [1, 2, 3, ...],
    api_token: '<Api-Token>'
}
```
### Test your Configuration

Test your setup by running the following command. This will post each stage's
message to Slack in turn.

```
$ cap production telegram:deploy:test
```

## Usage

Deploy your application like normal and you should see messages in the channel
you specified.

## Customizing the Messaging

You can customize the messaging posted to Slack by providing your own messaging
class and overriding several methods. Here is one example:

```ruby
module Telistrano
  class CustomMessaging < Messaging::Base

    # Send failed message to #ops. Send all other messages to default channels.
    # The #ops channel must exist prior.
    def channels_for(action)
      if action == :failed
        "#ops"
      else
        super
      end
    end

    # Suppress updating message.
    def payload_for_updating
      nil
    end

    # Suppress reverting message.
    def payload_for_reverting
      nil
    end

    # Fancy updated message.
    # See https://api.slack.com/docs/message-attachments
    def payload_for_updated
      {
        attachments: [{
          color: 'good',
          title: 'Integrations Application Deployed :boom::bangbang:',
          fields: [{
            title: 'Environment',
            value: stage,
            short: true
          }, {
            title: 'Branch',
            value: branch,
            short: true
          }, {
            title: 'Deployer',
            value: deployer,
            short: true
          }, {
            title: 'Time',
            value: elapsed_time,
            short: true
          }],
          fallback: super[:text]
        }]
      }
    end

    # Default reverted message.  Alternatively simply do not redefine this
    # method.
    def payload_for_reverted
      super
    end

    # Slightly tweaked failed message.
    # See https://api.slack.com/docs/message-formatting
    def payload_for_failed
      payload = super
      payload[:text] = "OMG :fire: #{payload[:text]}"
      payload
    end

    # Override the deployer helper to pull the full name from the password file.
    # See https://github.com/phallstrom/slackistrano/blob/master/lib/slackistrano/messaging/helpers.rb
    def deployer
      Etc.getpwnam(ENV['USER']).gecos
    end
  end
end
```

To set this up:

1. Add the above class to your app, for example `lib/custom_messaging.rb`.

2. Require the library after the requiring of Telistrano in your application's Capfile.

   ```ruby
   require_relative 'lib/custom_messaging'
   ```

3. Update the `telistrano` configuration in `config/deploy.rb` and add the `klass` option.

   ```ruby
   set :telistrano, {
     klass: Telistrano::CustomMessaging,
     chat_ids: [1, 2, 3, ...],
     api_token: '<Api-Token>'
   }
   ```

