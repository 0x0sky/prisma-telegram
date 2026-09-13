# © 2026 aiaiaiai · aiaiaiai.org

module PrismHubot
  module Handlers
    class Cancel
      def initialize(message_sender:)
        @message_sender = message_sender
      end

      def call(update:, arguments:)
        @message_sender.send_message(
          **update.reply_target,
          text: Copy::CANCELLED
        )
        PrismBot::Domain::InteractionTransition.clear
      end
    end
  end
end
