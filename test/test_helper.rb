# © 2026 aiaiaiai · aiaiaiai.org

require "minitest/autorun"
require "tmpdir"
require_relative "../lib/prism_hubot"

module PrismHubotTestSupport
  class MemoryStateStore
    attr_reader :values

    def initialize
      @values = {}
    end

    def load(key:)
      @values[key]
    end

    def store(key:, state:)
      @values[key] = state
    end

    def delete(key:)
      @values.delete(key)
    end
  end

  class MessageSender
    attr_reader :messages

    def initialize
      @messages = []
    end

    def send_message(chat_id:, text:)
      @messages << {chat_id: chat_id, text: text}
    end
  end

  class PublishPublication
    attr_reader :calls

    def initialize(error: nil)
      @error = error
      @calls = []
    end

    def call(publication:, idempotency_key:)
      raise @error if @error

      @calls << {publication: publication, idempotency_key: idempotency_key}
      {
        "status" => "ok",
        "request_id" => "request-test",
        "result" => {"data" => {"outcomes" => []}}
      }
    end
  end

  class ListChannels
    def call
      []
    end
  end

  class BotLifecycle
    def status(**)
      PrismBot::Domain::BotLifecycleState.new(status: "active")
    end

    def pause(**)
      PrismBot::Domain::BotLifecycleState.new(status: "paused")
    end

    def resume(**)
      PrismBot::Domain::BotLifecycleState.new(status: "active")
    end
  end

  module_function

  def services(message_sender:, publish_publication:)
    PrismBot::Client::Services.new(
      instance_id: "prism-hubot",
      default_channel_ids: ["personal-threads"],
      default_locale: "uk-UA",
      default_voice_profile: "0x0sky.uk_SP",
      dispatch_policy: "require_all_valid",
      message_sender: message_sender,
      list_channels: ListChannels.new,
      publish_publication: publish_publication,
      bot_lifecycle: BotLifecycle.new
    )
  end

  def authorized_update(text:, update_id:)
    update = PrismBot::Channels::Telegram::Update.new(
      update_id: update_id,
      chat_id: 100,
      user_id: 7,
      text: text
    )
    actor = PrismBot::Domain::HumanActor.new(
      canonical_id: "0x0sky",
      role: "owner"
    )
    PrismBot::Channels::Telegram::AuthorizedUpdate.new(
      update: update,
      actor: actor
    )
  end

  def interaction_key
    PrismBot::Domain::InteractionKey.new(
      instance_id: "prism-hubot",
      surface: "telegram",
      actor_ref: "person:0x0sky"
    )
  end

  def router(composition)
    command_router = PrismBot::Channels::Telegram::CommandRouter.new(
      handlers: composition.command_handlers,
      fallback: composition.fallback
    )
    PrismBot::Channels::Telegram::InteractionRouter.new(
      command_router: command_router,
      state_handlers: composition.state_handlers,
      state_store: composition.state_store,
      instance_id: "prism-hubot"
    )
  end
end
