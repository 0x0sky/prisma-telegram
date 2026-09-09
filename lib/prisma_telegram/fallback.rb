# © 2026 aiaiaiai · aiaiaiai.org

module PrismaTelegram
  class Fallback
    TRIGGERS = ["зробити допис", "create post"].freeze

    def initialize(begin_post:, fallback:)
      @begin_post = begin_post
      @fallback = fallback
    end

    def call(update:, arguments:)
      if TRIGGERS.include?(String(arguments).strip.downcase)
        return @begin_post.call(update: update, arguments: "")
      end

      @fallback.call(update: update, arguments: arguments)
    end
  end
end
