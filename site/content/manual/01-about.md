---
title: About
desc: What omarchy-gentoo is — an unofficial community overlay porting Omarchy's Arch packages to Gentoo — and what it is not.
---
## What this is

Omarchy on Gentoo is a community port of [Omarchy](https://omarchy.org) —
DHH's Arch-based Hyprland desktop — to **Gentoo Linux**: the same desktop
(Hyprland, the quickshell shell, SDDM, PipeWire, the Omarchy command line,
themes and default settings) shipped as source-based ebuilds in a Portage
overlay. No prebuilt packages, no ISO: Portage compiles everything on
your machine.

It is an **unofficial community overlay** — not affiliated with upstream
Omarchy, and not official Gentoo tooling. The brand rules (name, mark,
palette) are defined once in the repository's
[assets/logo/README.md](https://github.com/Lax/omarchy-gentoo/blob/master/assets/logo/README.md).

## What this is not

- **Not a fork of Omarchy.** Upstream's Arch recipes drive everything: CI
  reads them from the pinned `omacom/omarchy-pkgs` submodule and
  reconciles this tree against them around the clock.
- **Not an Omarchy usage guide.** Hotkeys and the AI tooling are
  upstream's story — [the official manual](https://omarchy.org/manual/)
  covers the desktop on any distro. The Gentoo side of themes and
  plugins is the exception: their commands work identically here, and
  [Themes](../themes/) / [Plugins](../plugins/) document what ships.
- **Not a Gentoo tutorial.** If Portage concepts are new, start with the
  [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64), then
  come back to [Install](../install/).

## Two trees, one overlay

What you add to Portage is the published overlay,
[Lax/omarchy-overlay](https://github.com/Lax/omarchy-overlay) — a
generated tree, replaced wholesale by CI on every change. Its `PROVENANCE`
file names the exact commits it was built from: this repository's master
and the pinned upstream recipes commit. All development, issues and
documentation happen at
[Lax/omarchy-gentoo](https://github.com/Lax/omarchy-gentoo); never edit
or open PRs against the published tree.

## Scope

The port targets what upstream's package recipes cover — the desktop, its
companion tools, and the default application set upstream ships on its
ISO — plus the patches and scripts those need to run under Portage. The
kernel, the bootloader and the Arch boot stack are deliberately out; on
Gentoo those are yours. See [Differences](../differences/).
