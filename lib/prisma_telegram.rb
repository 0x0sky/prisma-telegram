# © 2026 aiaiaiai · aiaiaiai.org

require "digest"
require "fileutils"
require "json"
require "securerandom"

require "prism_bot"

require_relative "prisma_telegram/configuration"
require_relative "prisma_telegram/copy"
require_relative "prisma_telegram/file_interaction_state_store"
require_relative "prisma_telegram/presenter"
require_relative "prisma_telegram/handlers/begin_post"
require_relative "prisma_telegram/handlers/await_post_content"
require_relative "prisma_telegram/handlers/cancel"
require_relative "prisma_telegram/fallback"
require_relative "prisma_telegram/client"

module PrismaTelegram
  class StateStoreError < PrismBot::Error; end
end
