# © 2026 aiaiaiai · aiaiaiai.org

require "json"
require "minitest/autorun"
require "rack/mock"
require "prism_bot"

class BootstrapTest < Minitest::Test
  def test_builds_runnable_client_from_prism_bot_infrastructure
    app = PrismBot::Bootstrap.build(
      env: environment,
      logger: Logger.new(IO::NULL)
    )

    response = Rack::MockRequest.new(app).get("/healthz")
    payload = JSON.parse(response.body)

    assert_equal 200, response.status
    assert_equal "ok", payload.fetch("status")
    assert_equal "prism-bot", payload.fetch("service")
  end

  def test_client_defaults_are_explicit
    configuration = PrismBot::Configuration.new(environment)

    assert_equal "prisma-telegram", configuration.instance_id
    assert_equal "uk-UA", configuration.default_locale
    assert_equal "0x0sky.uk_SP", configuration.default_voice_profile
    assert_equal "require_all_valid", configuration.dispatch_policy
  end

  private

  def environment
    {
      "PRISM_BOT_INSTANCE_ID" => "prisma-telegram",
      "PRISM_BOT_TELEGRAM_TOKEN" => "telegram-test-token",
      "PRISM_BOT_TELEGRAM_WEBHOOK_SECRET" => "a" * 32,
      "PRISM_BOT_TELEGRAM_ALLOWED_CHAT_IDS" => "[]",
      "PRISM_BOT_DEFAULT_CHANNEL_IDS" => "[]",
      "PRISM_BOT_DEFAULT_LOCALE" => "uk-UA",
      "PRISM_BOT_DEFAULT_VOICE_PROFILE" => "0x0sky.uk_SP",
      "PRISM_BOT_DISPATCH_POLICY" => "require_all_valid",
      "PRISM_HUB_BASE_URL" => "https://hub.example.test",
      "PRISM_HUB_API_TOKEN" => "h" * 32,
      "PRISM_BOT_MAX_WEBHOOK_BYTES" => "1048576",
      "PRISM_BOT_ALLOW_INSECURE_HTTP" => "false"
    }
  end
end
