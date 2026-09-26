<h1 align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo/omarchy-gentoo-lockup-dark.svg">
    <img src="assets/logo/omarchy-gentoo-lockup-light.svg" alt="Omarchy on Gentoo — Omarchy packages for Gentoo Linux" width="640">
  </picture>
</h1>

Omarchy packages for Gentoo Linux, as a source-based ebuild overlay.

This is the development home. The overlay users add to Portage lives at
[Lax/omarchy-overlay](https://github.com/Lax/omarchy-overlay) — CI
republishes this repository's `gentoo/` directory there on every merge to
master, and its
[README](https://github.com/Lax/omarchy-overlay#readme) carries the
install instructions (the `omarchy/omarchy` desktop core, or
`omarchy/omarchy-base` for the full default application set). The former
mirror, [omarchy-gentoo-archive](https://github.com/Lax/omarchy-gentoo-archive),
is archived and read-only — do not add it to Portage.

## Layout

```
omarchy-pkgs/  submodule: omacom/omarchy-pkgs (the Arch recipes, pinned)
gentoo/        the ebuild overlay (published to Lax/omarchy-overlay)
bin/           ai-port, sync-gentoo, scaffold-ebuild, gentoo-resolve
helpers/       conversion rules and ported/skipped bookkeeping
.github/       three workflows: gates, tooling self-tests, upstream sync
```

## How it maintains itself

- Upstream Omarchy changes are picked up automatically, and the overlay is
  republished as they land.
- A package is really built every night to catch breakage early.
- When something needs judgement, an issue is filed automatically — and
  closed again by the next green run.

Maintained by automation and coding agents: `AGENTS.md` is the agent
playbook, `docs/gentoo.md` the full contract (translation rules, scope,
the self-managed loop).

## Branding

The project is **Omarchy on Gentoo** — the Omarchy desktop, ported to
Gentoo Linux — while the repository slug stays
`omarchy-gentoo` (lowercase, hyphenated) and the Portage repository users
configure is `omarchy`. Canonical forms, palette, and the asset inventory
live in [`assets/logo/README.md`](assets/logo/README.md).
