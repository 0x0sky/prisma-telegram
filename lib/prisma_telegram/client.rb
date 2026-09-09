# © 2026 aiaiaiai · aiaiaiai.org

module PrismaTelegram
  class Client
    def initialize(state_store:, presenter: Presenter.new)
      @state_store = state_store
      @presenter = presenter
    end

    def call(services)
      base = PrismBot::Client::Default.new(presenter: @presenter).call(services)
      begin_post = Handlers::BeginPost.new(message_sender: services.message_sender)
      cancel = Handlers::Cancel.new(message_sender: services.message_sender)
      await_post_content = Handlers::AwaitPostContent.new(
        publish_handler: base.command_handlers.fetch("publish"),
        message_sender: services.message_sender
      )

      base.with(
        command_handlers: {
          "post" => begin_post,
          "cancel" => cancel
        },
        state_handlers: {
          "awaiting_post_content" => await_post_content
        },
        fallback: Fallback.new(begin_post: begin_post, fallback: base.fallback),
        state_store: @state_store
      )
    end
  end
end
