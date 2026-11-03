# MyNotes security review

Based on upstream `fastrepl/anarlog` at commit `428903e` (pinned in `UPSTREAM`).
Status key: DONE = patched in this repo, TODO = planned, UNVERIFIED = needs a check.

## Hidden instructions ("don't tell the user")
Searched the repo for phrases such as "do not tell", "don't mention", "ignore previous instructions",
"without telling the user". Three hits, none hostile:
- two output-style rules in summary prompts (`daily-summary.system.md.jinja`, `past-note-key-facts.system.md.jinja`)
- one docs rule about not telling people to edit the SQLite file directly (`docs/AGENTS.md`)

Not yet done: a line-by-line read of every `AGENTS.md` and `.cursor/skills/*`. Status: TODO.

## Network egress and remote control
| Item | Risk | Status |
|---|---|---|
| Sentry crash reports (`SENTRY_DSN` baked in at build) | Sends error data off the machine | DONE: DSN never read (patch 0001) |
| PostHog analytics (`POSTHOG_API_KEY`, required by release builds) | Sends usage data off the machine | DONE: key never read (patch 0001) |
| Auto-updater pointing at `desktop.anarlog.so` | Third party could ship new code to the app | DONE: endpoints removed, updater inactive (patch 0001). UNVERIFIED: that the updater plugin starts cleanly with no endpoints |
| OpenTelemetry / Honeycomb tracing (`plugins/tracing`) | Possible trace export | TODO |
| Meeting screen capture (every 3 s, `capture_shared_screens`) | Captures other people's shared screens | TODO: remove code; default not yet checked |
| Chrome extension native host (`crates/chrome-native-host`) | Extra local attack surface | TODO: remove |
| Cloud sync, auth, sharing, Supabase, hosted AI | Account and data egress | TODO: remove or disable |
| `plugins/relay` local TCP listener (127.0.0.1) | Local server | UNVERIFIED: compiled only in debug/devtools builds |
| `plugins/local-api`, `plugins/mcp`, `plugins/agent`, `plugins/hooks` | Local control surfaces | TODO: review, likely remove |

## Build and supply chain
- Upstream CI `.github/workflows/opencode.yml` runs an AI agent when someone comments `/oc` and carries a secret. Not copied here.
- Upstream dev and CI scripts use `curl | sh` (rustup, dprint, doxxer). Not used here.
- `enterprise/` is deleted by `bootstrap.sh` (commercial license).
- Our macOS build workflow must use no secrets and pin action versions by commit SHA. TODO.

## Allowed network destinations (target)
- The user-chosen AI endpoint for summaries (Anthropic API), and only when a key is entered.
- Model downloads for local transcription (Hugging Face or similar). UNVERIFIED which host.
- Nothing else.
