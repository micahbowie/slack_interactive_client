
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "slack_interactive_client/version"

Gem::Specification.new do |spec|
  spec.name          = "slack_interactive_client"
  spec.version       = SlackInteractiveClient::VERSION
  spec.authors       = ["Micah Bowie", "Code Cowboy"]
  spec.email         = ["micahbowie20@gmail.com"]

  spec.summary       = 'Interact with your Rails app through Slack by defining dynamic Slack slash commands, using a reusable message DSL, slack client, and more.'
  spec.description   = 'Interact with your Rails app through Slack by defining dynamic Slack slash commands, using a reusable message DSL, slack client, and more.'

  spec.files = Dir['lib/**/*'] + Dir['spec/**/*']

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/micahbowie/slack_interactive_client/issues",
    "changelog_uri"     => "https://github.com/micahbowie/slack_interactive_client/CHANGELOG.md",
    "documentation_uri" => "https://github.com/micahbowie/slack_interactive_client",
    "source_code_uri"   => "https://github.com/micahbowie/slack_interactive_client",
  }

  spec.required_ruby_version = ">= 2.7.0"
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'slack-ruby-client', '~> 1.0'
  spec.add_dependency 'rails'
  spec.add_dependency 'httparty'

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
end
