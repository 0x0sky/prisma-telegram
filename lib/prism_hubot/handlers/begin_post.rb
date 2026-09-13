# © 2026 aiaiaiai · aiaiaiai.org

module PrismHubot
  module Handlers
    class BeginPost
      STATE = PrismBot::Domain::InteractionState.new(
        name: "awaiting_post_content"
      )

      def initialize(message_sender:)
        @message_sender = message_sender
      end

      def call(update:, arguments:)
        @message_sender.send_message(
          **update.reply_target,
          text: Copy::POST_PROMPT
        )
        PrismBot::Domain::InteractionTransition.set(STATE)
      end
    end
  end
end
