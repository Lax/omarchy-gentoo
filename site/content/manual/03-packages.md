---
title: Packages
desc: What the omarchy overlay ships, what it skips (with cause), and what is still open in the port queue — generated from the tree at build time.
---
Three states cover every upstream Omarchy package. A package **ships**
when it has a row in `helpers/gentoo-packages.tsv` and an ebuild
directory; it is **skipped** when `helpers/gentoo-skip.tsv` records a
cause; anything else upstream ships is **open** in the port queue. The
tables below are generated from those files at build time — the same
sources the nightly coverage job and `bin/ai-port --list-open` read — so
this page cannot drift from the tree.

@@generated:packages@@
