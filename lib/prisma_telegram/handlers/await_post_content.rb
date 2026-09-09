# © 2026 aiaiaiai · aiaiaiai.org

module PrismaTelegram
  module Handlers
    class AwaitPostContent
      def initialize(publish_handler:, message_sender:)
        @publish_handler = publish_handler
        @message_sender = message_sender
      end

      def call(update:, state:)
        text = String(update.text).strip
        if text.empty?
          @message_sender.send_message(
            chat_id: update.chat_id,
            text: Copy::EMPTY_POST
          )
          return PrismBot::Domain::InteractionTransition.keep
        end

        @publish_handler.call(update: update, arguments: text)
        PrismBot::Domain::InteractionTransition.clear
      end
    end
  end
end
