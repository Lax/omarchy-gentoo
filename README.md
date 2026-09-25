<h1 align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo/omarchy-gentoo-lockup-dark.svg">
    <img src="assets/logo/omarchy-gentoo-lockup-light.svg" alt="Omarchy on Gentoo — Omarchy packages for Gentoo Linux" width="640">
  </picture>
</h1>

Omarchy packages for Gentoo Linux, as a source-based ebuild overlay.

The ebuilds live in the [omarchy-overlay](https://github.com/Lax/omarchy-overlay) repository — add it to Portage and install what you need. This repository is the development home: it follows [upstream Omarchy](https://github.com/omacom/omarchy-pkgs)'s package recipes and republishes the overlay automatically as they change. The former mirror, [omarchy-gentoo-archive](https://github.com/Lax/omarchy-gentoo-archive), is archived and read-only — do not add it to Portage.

Maintained by automation and coding agents. `AGENTS.md` is the playbook; `docs/gentoo.md` is the full contract (translation rules, scope, the self-managed loop).

## Using the overlay

```bash
eselect repository add omarchy git https://github.com/Lax/omarchy-overlay.git
emaint sync -r omarchy
```

### Install Omarchy

**Minimal** — the desktop core:

```bash
emerge app-misc/omarchy
```

That brings in the Hyprland session, the quickshell desktop shell, the SDDM
login manager, PipeWire audio, the screen-share portals and the Omarchy
command line, themes and default settings (`app-misc/omarchy-settings`,
upgraded in lockstep with the core).

**Full** — the core plus the default application set upstream ships on its
ISO (147 packages: browsers, terminal tools, printing, containers, ...):

```bash
emerge app-misc/omarchy-base
```

It maps [upstream's `omarchy-base.packages`](https://github.com/basecamp/omarchy/blob/master/install/omarchy-base.packages)
onto Gentoo; entries ::gentoo no longer ships or that are Arch-only are left
out, and the ebuild comments list every omission with its reason.

The kernel and bootloader are not part of this — on Gentoo those are yours
to run; the Arch boot stack is intentionally not ported.

Everything is keyworded `~amd64`/`~arm64` and the `-bin` packages carry
proprietary licenses — accept them as usual, e.g.
`*/* all-rights-reserved` in `/etc/portage/package.license`. If you don't
use eselect-repository, `docs/gentoo.md` has a hand-written variant.

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

## Branding

The project is **Omarchy on Gentoo** — the Omarchy desktop, ported to
Gentoo Linux — while the repository slug stays
`omarchy-gentoo` (lowercase, hyphenated) and the Portage repository users
configure is `omarchy`. The mark frames the official Gentoo signet **g**
inside omarchy's bracket ring — the g climbs a four-step band ladder from
omarchy green into gentoo purple; the wordmark is JetBrains Mono.
Canonical forms, palette, the `logo.svg` / `logo.txt` / `icon.png` trio,
and asset inventory live in
[`assets/logo/README.md`](assets/logo/README.md).
