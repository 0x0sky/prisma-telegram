# © 2026 aiaiaiai · aiaiaiai.org

require "bundler/setup"
require "prism_bot"

run PrismBot::Bootstrap.build(env: ENV)
