---
title: Differences from Arch Omarchy
desc: What the Gentoo port changes next to upstream Omarchy — source builds, no ISO, no boot stack, runtime package-name mapping.
---
## Everything compiles on your machine

This is a source-based overlay — there is no binhost. The desktop core
and especially the full application set build from source, browsers
included. Desktop-sized closures take a while; that is the price of
source-based Gentoo, not a defect of the port. `emerge --pretend -v`
prints the closure before you commit.

## No ISO, no installer

You install Gentoo first (the
[Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)), then add
the overlay — [Install](../install/) has the commands. Upstream's ISO and
its boot stack (Limine and friends) are Arch payloads and are
deliberately not ported; the kernel and bootloader remain yours, as they
are on any Gentoo system.

## omarchy-pkg-add speaks both names

Omarchy's scripts and docs install packages by their Arch names. The
ported `omarchy-pkg-add` carries a runtime Arch→Gentoo rename table, so
those invocations resolve to the right Portage atoms — including the
renames where Gentoo convention differs (dropped `-git` suffixes, dropped
`ttf-` prefixes, merged package families, and so on).

## Old addresses keep working, for a while

As the port matured, branded packages were gathered into the `omarchy/`
and `omarchy-extra/` categories. The old-category locations survive as
empty migration shims, so early installs still resolve; the shims are
dropped once users have moved over.

## The gaps

Some upstream packages do not exist here yet, or are skipped with a
recorded cause — proprietary payloads without a Gentoo provider, Arch-only
machinery, later waves of porting work. The
[coverage page](../packages/#skipped) is the authoritative list; this page
deliberately does not repeat it.

Themes and plugins have their own pages, because their story is mostly
"identical": [Themes](../themes/) and [Plugins](../plugins/) cover the
commands (upstream's, unmodified), what the overlay ships around them,
and the few helpers still pending.

Two Gentoo-side realities upstream does not have: everything is
`~arch`-keyworded, and the `-bin` packages carry proprietary licenses —
both accepted the usual Portage way ([Troubleshooting](../troubleshooting/)).
