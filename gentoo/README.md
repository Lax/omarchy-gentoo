<h1 align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Lax/omarchy-gentoo/master/assets/logo/omarchy-gentoo-lockup-dark.svg">
    <img src="https://raw.githubusercontent.com/Lax/omarchy-gentoo/master/assets/logo/omarchy-gentoo-lockup-light.svg" alt="Omarchy on Gentoo — Omarchy packages for Gentoo Linux" width="640">
  </picture>
</h1>

The [Omarchy](https://github.com/basecamp/omarchy) desktop for Gentoo
Linux — Hyprland, quickshell and the tools around them — as source-based
ebuilds. A community port, not affiliated with upstream Omarchy.

This tree is generated: CI mirrors it from
[Lax/omarchy-gentoo](https://github.com/Lax/omarchy-gentoo) (the
`gentoo/` directory) on every upstream change, so it stays in lockstep
with Omarchy's Arch package recipes. Don't edit or open PRs here —
everything happens in omarchy-gentoo; report problems to its
[issue tracker](https://github.com/Lax/omarchy-gentoo/issues).

## Add the overlay

```bash
eselect repository add omarchy git https://github.com/Lax/omarchy-overlay.git
emaint sync -r omarchy
```

Without eselect-repository, hand-write the same thing:

```ini
# /etc/portage/repos.conf/omarchy.conf
[omarchy]
location = /var/db/repos/omarchy
sync-type = git
sync-uri = https://github.com/Lax/omarchy-overlay.git
priority = 50
```

Keep the tree current with `emaint sync -r omarchy`.

## Install Omarchy

The desktop core pulls Hyprland and quickshell from two companion
overlays — add them alongside:

```bash
eselect repository enable guru
eselect repository add hyproverlay git https://codeberg.org/hyproverlay/hyproverlay.git
emaint sync -r guru -r hyproverlay
```

**Minimal** — the desktop core: the Hyprland session, the quickshell
desktop shell, the SDDM login manager, PipeWire audio, the screen-share
portals and the Omarchy command line, themes and default settings:

```bash
emerge omarchy/omarchy
```

**Full** — the core plus the default application set upstream ships on
its ISO (147 packages: browsers, terminal tools, printing, containers,
...):

```bash
emerge omarchy/omarchy-base
```

Entries ::gentoo no longer ships or that are Arch-only are left out; the
`omarchy-base` ebuild comments list every omission with its reason.

The kernel and bootloader are not part of this — on Gentoo those are
yours to run; the Arch boot stack is intentionally not ported.

## Before you emerge

- Everything is keyworded `~amd64` / `~arm64`; accept the unstable
  keyword as usual.
- The `-bin` packages carry proprietary licenses; accept them as usual,
  e.g. `*/* all-rights-reserved` in `/etc/portage/package.license`.
- Everything builds from source on your machine; desktop-sized closures
  take a while.
- Run the install with `--autounmask-write --autounmask-continue
  --autounmask-backtrack=y`; if a USE constraint violation is reported
  (e.g. dev-qt/qtbase wanting `libproxy` also requires `network`), enable
  the implied flags together in `/etc/portage/package.use` and re-run.

## Provenance

Each publish records the omarchy-gentoo master commit this tree was
generated from and the [omacom/omarchy-pkgs](https://github.com/omacom/omarchy-pkgs)
commit its recipes reflect — see [PROVENANCE](PROVENANCE) and the mirror
commit messages.
