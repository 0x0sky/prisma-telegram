# prisma-telegram

Personal Telegram client for multi-channel publishing through Prism.

`prisma-telegram` is the first concrete client product built on [`aiaiaiai-org/prism-bot`](https://github.com/aiaiaiai-org/prism-bot). It composes shared bot infrastructure instead of reimplementing Telegram transport, Prism Hub authorisation, lifecycle, or publishing behaviour.

## Current client

The initial slice consumes an immutable `aiaiaiai-prism-bot` commit and exposes its runnable Telegram webhook application.

Available interaction infrastructure currently includes:

- `/start` — onboard or resolve the Telegram user through Prism Hub;
- `/help` — show supported commands;
- `/status` — read the caller-owned bot lifecycle state;
- `/stop` — persistently pause the caller-owned logical bot instance;
- `/resume` — resume a paused instance;
- `/channels` — list Hub-authorised publishing channels;
- `/publish text` — publish text through configured default channels;
- `/publish [channel-a,channel-b] text` — publish to explicit Hub channel IDs.

Provider credentials never enter this client. Telegram identity evidence, human authorisation, social-account access, channels, and publication permissions are resolved server-side by Prism Hub.

## Run locally

Ruby `4.0.6` is pinned in `.ruby-version`.

```bash
bundle install
cp .env.example .env
set -a && source .env && set +a
bundle exec rackup config.ru -s Puma -p 9292
```

Configure Telegram to send updates to `/telegram/webhook` using the same webhook secret as `PRISM_BOT_TELEGRAM_WEBHOOK_SECRET`. `/healthz` is available for process liveness.

## Configuration

`.env.example` defines the complete current runtime contract. Client defaults are explicit:

- instance: `prisma-telegram`;
- locale: `uk-UA`;
- voice profile: `0x0sky.uk_SP`;
- dispatch policy: `require_all_valid`.

Channel IDs remain empty until Hub exposes the concrete accounts/channels this client may publish to.

## Architecture

```text
Telegram
  -> prisma-telegram
  -> aiaiaiai-prism-bot
  -> prism-hub API v1
  -> prism-execution.v1
  -> prism
```

See [`docs/architecture.md`](docs/architecture.md) for ownership and dependency rules.

The next product-facing increment is not another backend. `prism-bot` needs an explicit reusable client-composition boundary so `prisma-telegram` can define its own conversational UX — for example, “create post” followed by the next message as content — while continuing to reuse the same identity, lifecycle, channel, and publication infrastructure.

## Verification

```bash
bundle exec rubocop
bundle exec rake test
bundle exec bundle-audit check --update
```

No repository licence has been selected yet. Do not infer the licence of `prism-bot` or `prism` for this repository.

<!-- © 2026 aiaiaiai · aiaiaiai.org -->
