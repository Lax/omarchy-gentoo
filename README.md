<h1 align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo/omarchy-gentoo-lockup-dark.svg">
    <img src="assets/logo/omarchy-gentoo-lockup-light.svg" alt="Omarchy on Gentoo — Omarchy packages for Gentoo Linux" width="640">
  </picture>
</h1>

Omarchy packages for Gentoo Linux, as a source-based ebuild overlay.

The Arch recipes live in the pinned [`omarchy-pkgs/` submodule](https://github.com/omacom/omarchy-pkgs); this repository turns them into ebuilds, validates them in a Gentoo stage3 container, and publishes the result to the [omarchy-overlay](https://github.com/Lax/omarchy-overlay) repository — which is what Portage users sync.

Maintained by automation and coding agents. `AGENTS.md` is the playbook; `docs/gentoo.md` is the full contract (translation rules, scope, the self-managed loop).

## Using the overlay

The overlay is a repository of its own and its tree root IS the overlay,
so syncing is one command:

```bash
eselect repository add omarchy git https://github.com/Lax/omarchy-overlay.git
emaint sync -r omarchy
```

Or hand-write the repository definition:

```ini
# /etc/portage/repos.conf/omarchy.conf
[omarchy]
location = /var/db/repos/omarchy
sync-type = git
sync-uri = https://github.com/Lax/omarchy-overlay.git
priority = 50
```

Then `emerge <category>/<package>`. Keyword `~amd64`/`~arm64` as usual, and accept the proprietary licenses of the `-bin` packages, e.g. `*/* all-rights-reserved` in `/etc/portage/package.license`. See `docs/gentoo.md` for details.

## Layout

```
omarchy-pkgs/  submodule: omacom/omarchy-pkgs (the Arch recipes, pinned)
gentoo/        the ebuild overlay (published to Lax/omarchy-overlay)
bin/           ai-port, sync-gentoo, scaffold-ebuild, gentoo-resolve
helpers/       conversion rules and ported/skipped bookkeeping
.github/       three workflows: gates, tooling self-tests, upstream sync
```

## How it maintains itself

- Every 3h, `Upstream sync` advances the submodule pin, reconciles ebuild versions against the new recipes, and pushes to master — filing an agent-actionable issue whenever a rename needs judgement.
- Nightly, the overlay loop really emerges one rotating package in a fresh Gentoo stage3 on the self-hosted runner (gated on the drift check), re-checks for drift, files the porting backlog as an issue, and publishes `gentoo/` to the omarchy-overlay repository on push.
- Any gate failure files an issue with the run link. Fix, push, and the next green run closes the loop.

## Branding

The project is **Omarchy on Gentoo** — an intentional echo of Ruby on
Rails, by the same author — while the repository slug stays
`omarchy-gentoo` (lowercase, hyphenated) and the Portage repository users
configure is `omarchy`. The mark frames the official Gentoo signet **g**
inside omarchy's bracket ring — the g climbs a four-step band ladder from
omarchy green into gentoo purple; the wordmark is JetBrains Mono.
Canonical forms, palette, the `logo.svg` / `logo.txt` / `icon.png` trio,
and asset inventory live in
[`assets/logo/README.md`](assets/logo/README.md).
