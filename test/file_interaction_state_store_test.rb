# © 2026 aiaiaiai · aiaiaiai.org

require_relative "test_helper"

class FileInteractionStateStoreTest < Minitest::Test
  include PrismaTelegramTestSupport

  def test_state_survives_store_recreation
    Dir.mktmpdir do |directory|
      clock = 1_000
      first = PrismaTelegram::FileInteractionStateStore.new(
        directory: directory,
        ttl_seconds: 900,
        clock: -> { clock }
      )
      state = PrismBot::Domain::InteractionState.new(
        name: "awaiting_post_content",
        data: {"source" => "post"}
      )

      first.store(key: interaction_key, state: state)

      second = PrismaTelegram::FileInteractionStateStore.new(
        directory: directory,
        ttl_seconds: 900,
        clock: -> { clock }
      )
      restored = second.load(key: interaction_key)

      assert_equal state.name, restored.name
      assert_equal state.data, restored.data
    end
  end

  def test_expired_state_is_removed
    Dir.mktmpdir do |directory|
      clock = 1_000
      store = PrismaTelegram::FileInteractionStateStore.new(
        directory: directory,
        ttl_seconds: 10,
        clock: -> { clock }
      )
      state = PrismBot::Domain::InteractionState.new(name: "awaiting_post_content")
      store.store(key: interaction_key, state: state)

      clock = 1_011

      assert_nil store.load(key: interaction_key)
      assert_empty Dir.children(directory)
    end
  end

  def test_file_name_does_not_expose_actor_reference
    Dir.mktmpdir do |directory|
      store = PrismaTelegram::FileInteractionStateStore.new(
        directory: directory,
        ttl_seconds: 10
      )
      state = PrismBot::Domain::InteractionState.new(name: "awaiting_post_content")

      store.store(key: interaction_key, state: state)

      refute_includes Dir.children(directory).first, "0x0sky"
    end
  end
end
