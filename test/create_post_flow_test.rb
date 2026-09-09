# © 2026 aiaiaiai · aiaiaiai.org

require_relative "test_helper"

class CreatePostFlowTest < Minitest::Test
  include PrismaTelegramTestSupport

  def setup
    @store = MemoryStateStore.new
    @sender = MessageSender.new
    @publisher = PublishPublication.new
    services = PrismaTelegramTestSupport.services(
      message_sender: @sender,
      publish_publication: @publisher
    )
    composition = PrismaTelegram::Client.new(state_store: @store).call(services)
    @router = PrismaTelegramTestSupport.router(composition)
  end

  def test_post_command_waits_for_next_message_then_publishes_and_clears
    @router.call(authorized_update(text: "/post", update_id: 1))

    state = @store.load(key: interaction_key)
    assert_equal "awaiting_post_content", state.name
    assert_equal PrismaTelegram::Copy::POST_PROMPT, @sender.messages.last.fetch(:text)

    @router.call(authorized_update(text: "мій перший допис", update_id: 2))

    assert_nil @store.load(key: interaction_key)
    assert_equal 1, @publisher.calls.length
    assert_equal "telegram:prisma-telegram:2", @publisher.calls.first.fetch(:idempotency_key)
    assert_includes @sender.messages.last.fetch(:text), "Prism завершив запит"
  end

  def test_control_command_has_priority_and_keeps_pending_state
    @router.call(authorized_update(text: "/post", update_id: 1))
    @router.call(authorized_update(text: "/help", update_id: 2))

    assert_equal "awaiting_post_content", @store.load(key: interaction_key).name
    assert_includes @sender.messages.last.fetch(:text), "/post"
    assert_empty @publisher.calls
  end

  def test_cancel_clears_pending_state
    @router.call(authorized_update(text: "/post", update_id: 1))
    @router.call(authorized_update(text: "/cancel", update_id: 2))

    assert_nil @store.load(key: interaction_key)
    assert_equal PrismaTelegram::Copy::CANCELLED, @sender.messages.last.fetch(:text)
  end

  def test_natural_text_trigger_starts_the_same_flow
    @router.call(authorized_update(text: "зробити допис", update_id: 1))

    assert_equal "awaiting_post_content", @store.load(key: interaction_key).name
  end

  def test_empty_follow_up_keeps_state
    @router.call(authorized_update(text: "/post", update_id: 1))
    @router.call(authorized_update(text: "   ", update_id: 2))

    assert_equal "awaiting_post_content", @store.load(key: interaction_key).name
    assert_equal PrismaTelegram::Copy::EMPTY_POST, @sender.messages.last.fetch(:text)
    assert_empty @publisher.calls
  end

  def test_publish_failure_keeps_state_for_retry
    failing_publisher = PublishPublication.new(
      error: PrismBot::TransportError.new("test.unavailable", "unavailable")
    )
    services = PrismaTelegramTestSupport.services(
      message_sender: @sender,
      publish_publication: failing_publisher
    )
    composition = PrismaTelegram::Client.new(state_store: @store).call(services)
    router = PrismaTelegramTestSupport.router(composition)

    router.call(authorized_update(text: "/post", update_id: 1))

    assert_raises(PrismBot::TransportError) do
      router.call(authorized_update(text: "retry me", update_id: 2))
    end
    assert_equal "awaiting_post_content", @store.load(key: interaction_key).name
  end
end
