# Architecture

`prisma-telegram` is a concrete Telegram client product for Prism. It is not a second publishing backend.

```text
Telegram
  |
  v
prisma-telegram
  |
  | consumes pinned aiaiaiai-prism-bot
  v
prism-bot
  |
  | Prism Hub API v1
  v
prism-hub
  |
  | prism-execution.v1
  v
prism
```

## Ownership

`prisma-telegram` owns only product composition and Telegram-facing product choices that are specific to this client, such as enabled interaction flows, copy, defaults, and deployment configuration.

`prism-bot` owns reusable messaging-client infrastructure: Telegram webhook verification and parsing, Hub identity resolution, per-user lifecycle gating, command/interaction plumbing, message delivery, generated Hub API integration, and reusable publishing use cases.

`prism-hub` owns human identity, workspaces, service principals, social accounts and access, channels, permissions, OAuth/credential lifecycle when implemented, and publication orchestration.

`prism` owns deterministic content variants, provider capabilities, preflight, dispatch, provider adapters, and typed delivery outcomes.

## Dependency rules

- `prisma-telegram` talks to providers only through `prism-bot` and Prism Hub contracts.
- Raw provider credentials never belong in this repository or Telegram messages.
- Client-specific UX must not be implemented by copying `prism-bot` internals.
- Shared behaviour needed by multiple bot clients moves down into `prism-bot` behind a stable client-composition boundary.
- `prism-bot` is pinned to an immutable commit until a released package/versioning channel replaces the Git dependency.
- Infrastructure upgrades are deliberate dependency updates with CI, never implicit changes from a floating branch.

## Current slice

The initial client uses the default `PrismBot::Bootstrap` composition unchanged. This proves the repository boundary and gives the client a runnable webhook application without duplicating shared logic.

The next infrastructure increment should expose an explicit client-composition contract for product-specific interaction routers, presenters, command sets, and conversational state. `prisma-telegram` will consume that contract rather than constructing or monkey-patching internal `prism-bot` objects.

<!-- © 2026 aiaiaiai · aiaiaiai.org -->
