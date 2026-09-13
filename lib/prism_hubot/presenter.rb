# © 2026 aiaiaiai · aiaiaiai.org

module PrismHubot
  class Presenter < PrismBot::Channels::Telegram::ResultPresenter
    def help
      Copy::HELP
    end

    def started(actor)
      unless actor.is_a?(PrismBot::Domain::HumanActor)
        raise ArgumentError, "actor must be a HumanActor"
      end

      "Prism Hubot готова. Публічний ID: #{actor.canonical_id}.\n\n#{help}"
    end

    def unknown
      "Невідома команда.\n\n#{help}"
    end
  end
end
