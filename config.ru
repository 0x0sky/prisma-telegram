# © 2026 aiaiaiai · aiaiaiai.org

require "bundler/setup"
require_relative "lib/prism_hubot"

configuration = PrismHubot::Configuration.new(ENV)
state_store = PrismHubot::FileInteractionStateStore.new(
  directory: configuration.state_directory,
  ttl_seconds: configuration.state_ttl_seconds
)
client = PrismHubot::Client.new(state_store: state_store)

run PrismBot::Bootstrap.build(env: ENV, client: client)
