# © 2026 aiaiaiai · aiaiaiai.org

module PrismHubot
  module Copy
    HELP = <<~TEXT.freeze
      Prism Hubot:
      /start — підключити себе до Prism
      /post — створити допис у два кроки
      /cancel — скасувати поточну дію
      /channels — доступні канали
      /status — поточний стан бота
      /stop — призупинити бота для себе
      /resume — відновити бота
      /publish текст — швидка публікація у типові канали
      /publish [channel-a,channel-b] текст — публікація у вибрані канали

      Можна також написати «зробити допис» без команди.
    TEXT

    POST_PROMPT = "Надішли текст допису наступним повідомленням. /cancel — скасувати.".freeze
    EMPTY_POST = "Текст допису порожній. Надішли текст або /cancel.".freeze
    CANCELLED = "Поточну дію скасовано.".freeze
  end
end
