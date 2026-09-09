# © 2026 aiaiaiai · aiaiaiai.org

module PrismaTelegram
  class Configuration
    DEFAULT_STATE_DIRECTORY = "var/interaction-state".freeze
    DEFAULT_STATE_TTL_SECONDS = 900

    attr_reader :state_directory, :state_ttl_seconds

    def initialize(environment)
      @state_directory = resolve_state_directory(environment)
      @state_ttl_seconds = positive_integer(
        environment.fetch(
          "PRISMA_TELEGRAM_INTERACTION_STATE_TTL_SECONDS",
          DEFAULT_STATE_TTL_SECONDS.to_s
        ),
        "PRISMA_TELEGRAM_INTERACTION_STATE_TTL_SECONDS"
      )
      freeze
    end

    private

    def resolve_state_directory(environment)
      value = String(
        environment.fetch(
          "PRISMA_TELEGRAM_INTERACTION_STATE_DIR",
          DEFAULT_STATE_DIRECTORY
        )
      ).strip
      if value.empty?
        raise PrismBot::ConfigurationError.new(
          "prisma_telegram.state_directory.invalid",
          "PRISMA_TELEGRAM_INTERACTION_STATE_DIR must not be empty"
        )
      end

      File.expand_path(value).freeze
    end

    def positive_integer(value, name)
      integer = Integer(value)
      return integer if integer.positive?

      raise ArgumentError
    rescue ArgumentError, TypeError
      raise PrismBot::ConfigurationError.new(
        "prisma_telegram.configuration.integer.invalid",
        "#{name} must be a positive integer"
      )
    end
  end
end
