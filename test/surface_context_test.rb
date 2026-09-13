# © 2026 aiaiaiai · aiaiaiai.org

require_relative "test_helper"

class SurfaceContextTest < Minitest::Test
  include PrismHubotTestSupport

  def setup
    @store = MemoryStateStore.new
    @sender = MessageSender.new
    @publisher = PublishPublication.new
    services = PrismHubotTestSupport.services(
      message_sender: @sender,
      publish_publication: @publisher
    )
    composition = PrismHubot::Client.new(state_store: @store).call(services)
    @router = PrismHubotTestSupport.router(composition)
  end

  def test_context_card_is_inherited_and_replies_in_the_origin_topic
    @router.call(
      authorized_update(
        text: "/context",
        update_id: 1,
        chat_id: -1001,
        chat_type: "supergroup",
        message_thread_id: 73,
        title: "Editorial"
      )
    )

    message = @sender.messages.last
    assert_equal(-1001, message.fetch(:chat_id))
    assert_equal 73, message.fetch(:message_thread_id)
    assert_includes message.fetch(:text), "Контекст: Editorial"
    assert_includes message.fetch(:text), "Тип: Гілка"
    assert_includes message.fetch(:text), "Topic ID: 73"
    assert_includes message.fetch(:text), "Прив’язка Hub: не перевірена"
  end

  def test_pending_post_state_is_isolated_by_topic_and_custom_replies_keep_topic
    @router.call(
      authorized_update(
        text: "/post",
        update_id: 1,
        chat_id: -1001,
        chat_type: "supergroup",
        message_thread_id: 73
      )
    )

    topic_key = interaction_key(chat_id: -1001, message_thread_id: 73)
    root_key = interaction_key(chat_id: -1001)
    assert_equal "awaiting_post_content", @store.load(key: topic_key).name
    assert_nil @store.load(key: root_key)
    assert_equal 73, @sender.messages.last.fetch(:message_thread_id)

    @router.call(
      authorized_update(
        text: "root message",
        update_id: 2,
        chat_id: -1001,
        chat_type: "supergroup"
      )
    )

    assert_equal "awaiting_post_content", @store.load(key: topic_key).name
    assert_empty @publisher.calls

    @router.call(
      authorized_update(
        text: "topic publication",
        update_id: 3,
        chat_id: -1001,
        chat_type: "supergroup",
        message_thread_id: 73
      )
    )

    assert_nil @store.load(key: topic_key)
    assert_equal 1, @publisher.calls.length
    assert_equal 73, @sender.messages.last.fetch(:message_thread_id)
  end
end
