# Architecture

`prisma-telegram` is a concrete Telegram client product for Prism. It is not a second publishing backend.

```text
Telegram
  |
  v
prisma-telegram
  |  product copy + interaction flows + client state adapter
  v
PrismBot::Client::Composition
  |
  v
prism-bot
  |  Prism Hub API v1
  v
prism-hub
  |  prism-execution.v1
  v
prism
```

## Ownership

`prisma-telegram` owns only product composition and Telegram-facing product choices specific to this client: enabled flows, copy, defaults, deployment configuration, and short-lived conversational state persistence.

`prism-bot` owns reusable messaging-client infrastructure: Telegram webhook verification and parsing, Hub identity resolution, per-user lifecycle gating, command/interaction routing, message delivery, generated Hub API integration, and reusable publishing use cases.

`prism-hub` owns human identity, workspaces, service principals, social accounts and access, channels, permissions, OAuth/credential lifecycle when implemented, and publication orchestration.

`prism` owns deterministic content variants, provider capabilities, preflight, dispatch, provider adapters, and typed delivery outcomes.

## Client composition

The client consumes the public `PrismBot::Client::Composition` contract. The built-in Prism Bot command set remains the base composition; this repository extends it with product behaviour rather than reconstructing Hub or webhook wiring.

The current extension adds:

- `/post` and the exact text `зробити допис` as create-post entry points;
- explicit `awaiting_post_content` interaction state;
- the next ordinary message as publication content;
- `/cancel` as a state-clearing control command;
- product-specific help/start/unknown copy.

Actual publication still runs through the shared Prism Bot `/publish` handler. The client does not construct provider requests and never receives provider credentials.

Commands have priority over pending conversational state. `/help`, `/status`, `/stop`, `/resume`, `/channels`, `/publish`, and `/cancel` therefore remain commands even while `awaiting_post_content` is active.

A successful awaited publication clears the state. If publishing raises a typed Hub/transport error, the interaction transition is never applied and the pending state remains available for a retry.

## Interaction state

Conversational state implements `PrismBot::Ports::InteractionStateStore` in `FileInteractionStateStore`.

The key is derived from the canonical interaction tuple:

```text
client instance + telegram surface + Hub-resolved canonical actor reference
```

The on-disk file name is a SHA-256 fingerprint of that tuple, so the actor reference is not exposed in the directory listing. Each state document contains only a format version, expiry timestamp, state name, and JSON-compatible state data.

Writes use a mode-`0600` temporary file, `fsync`, and atomic rename. States expire after a configurable TTL and are removed when next read. The implementation intentionally avoids process-global memory, so restarting the bot does not by itself discard an in-progress interaction.

This adapter assumes one active process over one state directory. A future horizontally scaled deployment should replace it with a shared store implementing the same port; the product flow does not change.

## Dependency rules

- `prisma-telegram` talks to providers only through `prism-bot` and Prism Hub contracts.
- Raw provider credentials never belong in this repository or Telegram messages.
- Client-specific UX must not be implemented by copying `prism-bot` internals.
- Shared behaviour needed by multiple bot clients moves down into `prism-bot` behind its public composition boundary.
- `prism-bot` is pinned to an immutable commit until a released package/versioning channel replaces the Git dependency.
- Infrastructure upgrades are deliberate dependency updates with CI, never implicit changes from a floating branch.
- The local interaction-state directory is operational client state, not identity, social-account, channel, credential, or publication truth.

<!-- © 2026 aiaiaiai · aiaiaiai.org -->
