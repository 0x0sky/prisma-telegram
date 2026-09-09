# © 2026 aiaiaiai · aiaiaiai.org

require "bundler/setup"
require_relative "lib/prisma_telegram"

configuration = PrismaTelegram::Configuration.new(ENV)
state_store = PrismaTelegram::FileInteractionStateStore.new(
  directory: configuration.state_directory,
  ttl_seconds: configuration.state_ttl_seconds
)
client = PrismaTelegram::Client.new(state_store: state_store)

run PrismBot::Bootstrap.build(env: ENV, client: client)
