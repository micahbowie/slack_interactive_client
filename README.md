# Slack Interactive Client

Slack Interactive Client is a wrapper around the `slack-ruby-client` gem. On top of a Slack client Slack Interactive Client also gives a custom message DSL for defining reusable slack messages, a way to define dynamic slack commands that allows you to interact with your Rails app right in slack, and a poor mans Rails console right in your Slack DMs. 

## Setup

Add this line to your application's Gemfile:

```ruby
gem 'slack_interactive_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slack_interactive_client

## Basic Usage

First you will need to configure the gem with your slack credentials
```
# config/initializers/slack_interactive_client.rb

SlackInteractiveClient::Client.configure do |config|
  config.auth_token = 'slack-bot-token'
end
```


You can define slack message templates by using the custom DSL as shown below:
```
# config/slack_templates.rb

SlackInteractiveClient::Message.define do
  template :allocation_error do
    title ":octagonal-sign: Allocation Error"
    text do |args|
      "Error: #{args[:error_class]}."
    end

    markdown_section { |args| args[:error_stack] }

    environment Rails.env
    channel '#servicing-alerts'
  end
end

```

To use a defined message template simply call the client and pass the name as a symbol. You can pass in a hash as a second argument.
this hash is what is passed to your message template.
```
SlackInteractiveClient::Client.send_message(:allocation_error, { error_class: error.class, error_stack: error.stacktrace })
```

## Advanced Message Usage

You can send CSV data with ease using the `csv_data true ` attribute in your template. This will configure your template automatically 
use the csv header and row arguments.
```
SlackInteractiveClient::Message.define do
  template :daily_allocation do
    title ":face_with_cowboy_hat: Daily allocation!"
    text "Here is the daily allocation data:"

    csv_data true 

    channel '#servicing-alerts'
    mention '@servicing-devs'
  end
end
```

Usage:

```
csv_data = {
    title: 'Allocation Data',
    filename: 'test_csv.csv',
    headers: ['loan', 'amount'],
    rows: [['df134', 100.00], ['904jrn', 125.00]]
    }

SlackInteractiveClient::Client.send_message(:daily_allocation, { csv: csv_data })
```


If you are looking to send code snippets, stack traces, etc use the `markdown_section` attribute in your template.
 ```
SlackInteractiveClient::Message.define do
  template :unexpected_error do
    title "Oh no something went wrong!"

    markdown_section { |args| args[:error] }

    channel '#servicing-alerts'
    mention '@servicing-devs'
  end
end
```


Usage:

```
error = <<~TEXT
  # Error Comment
  StandardError.new
TEXT

SlackInteractiveClient::Client.send_message(:unexpected_error, { error: error })
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
