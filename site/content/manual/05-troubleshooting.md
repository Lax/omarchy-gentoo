---
title: Troubleshooting
desc: Keywords, licenses, USE conflicts and slow builds — the Gentoo-side realities of installing the Omarchy overlay.
---
The canonical install steps live in the overlay README, embedded on the
[Install](../install/) page; this page expands the Gentoo-side realities it
mentions.

## Portage asks to accept keywords

Everything in the overlay is keyworded `~amd64` / `~arm64` — accept the
unstable keyword the usual Portage way, for example in
`/etc/portage/package.accept_keywords`:

```ini
*/*::omarchy ~amd64
```

Or keep the existing `package.accept_keywords` scheme you already use —
the overlay is not special here.

## Portage asks to accept licenses

The `-bin` packages carry proprietary licenses. Accept them as usual,
e.g. `*/* all-rights-reserved` in `/etc/portage/package.license`.

## USE constraint violations during the install

Run the install with the autounmask flags the
[install section](../install/#before-you-emerge) recommends. When Portage
reports a USE constraint violation — for example dev-qt/qtbase wanting
`libproxy` also requires `network` — enable the implied flags together in
`/etc/portage/package.use` and re-run. Autounmask writes most of this for
you; read what it proposes before letting it write.

## Builds take a (long) while

Nothing here ships binaries. The desktop core, and especially the full
application set, compile from source; expect hours for the full set on a
laptop, not minutes. Two mitigations that cost nothing:

- `emerge --pretend -v` shows the closure before you commit to it.
- The nightly smoke build catches breakage before it reaches the
  published overlay — if a nightly failed, the
  [issue tracker](https://github.com/Lax/omarchy-gentoo/issues) has an
  issue about it.

## Where to report

Report problems to the
[omarchy-gentoo issue tracker](https://github.com/Lax/omarchy-gentoo/issues) —
not against the published overlay repository, which is generated and
effectively read-only. Include `emerge --info`, the failing atom, and
which overlay commit you have synced (that repository's `PROVENANCE`
file names it).

Questions about *using* the desktop itself — keybindings, themes,
plugins — belong upstream: [omarchy.org](https://omarchy.org), its
[manual](https://omarchy.org/manual/), and its community channels.
