---
title: Omarchy on Gentoo
desc: The Omarchy desktop for Gentoo Linux — Hyprland, quickshell and the tools around them — as source-based ebuilds. An unofficial community overlay.
---
@@generated:status@@

## Try it

Add the overlay, sync it, and emerge the desktop core — or `omarchy-base`
for the full default application set (the [install page](manual/install/)
has the long version):

```bash
eselect repository add omarchy git https://github.com/Lax/omarchy-overlay.git
emaint sync -r omarchy
emerge omarchy/omarchy
```

<div class="cards">
  <a class="card" href="manual/packages/">
    <h3>What ships</h3>
    <p>The coverage table: every ported package, every skip with its recorded
    cause, and the live port queue — generated from the tree, not from prose.</p>
  </a>
  <a class="card" href="manual/differences/">
    <h3>How it differs</h3>
    <p>Source builds, no ISO, no Arch boot stack — what the Gentoo port
    changes next to upstream Omarchy, day to day.</p>
  </a>
  <a class="card" href="manual/developing/">
    <h3>How it maintains itself</h3>
    <p>Upstream syncs every three hours; gates, a nightly real build and
    automatic issue-filing keep the tree honest without humans.</p>
  </a>
</div>

@@generated:news-preview 3@@

New here? Omarchy itself is [upstream's distro](https://omarchy.org) — this
overlay brings its packages to Gentoo. Questions about *using* the desktop
belong in [the official manual](https://omarchy.org/manual/); questions
about the Gentoo side start at [About](manual/about/).
