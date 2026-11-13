---
title: Install
desc: Adding the omarchy overlay to Portage and emerging the Omarchy desktop on Gentoo.
---
The first section below is the published overlay's README, embedded
verbatim — when it and this page ever disagree, it wins. The sections
after it are site-only extras.

@@include gentoo/README.md@@

## Keeping the overlay current

The published tree moves with upstream: CI republishes it as upstream
Omarchy changes land, checked up to every three hours. Sync and upgrade
the usual way:

```bash
emaint sync -r omarchy
emerge --ask --deep --update --newuse @world
```

The ported Omarchy command line handles what it can; on Gentoo, system
updates remain Portage's job.

## Uninstalling

```bash
emerge --ask --depclean omarchy/omarchy omarchy/omarchy-base
eselect repository remove omarchy
```

The companion overlays (guru, hyproverlay) are ordinary overlays — remove
them the same way if nothing else on the machine uses them.

## Day-to-day

- See what an atom would pull before committing to the build:
  `emerge --pretend -v omarchy/omarchy`.
- Everything in the overlay carries the `omarchy::` repository tag, so it
  stays easy to tell apart from ::gentoo and the companion overlays.
- Omarchy's scripts and docs install packages by their Arch names; the
  ported `omarchy-pkg-add` resolves those to the right Portage atoms at
  runtime. See [Differences](../differences/).
