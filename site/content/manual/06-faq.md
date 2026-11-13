---
title: FAQ
desc: Short answers — officialness, ISOs, binary packages, updates, the omarchy CLI, missing packages.
---
**Is this official Omarchy?**

No — an unofficial community overlay, not affiliated with upstream Omarchy
or the Gentoo Foundation. [About](../about/) has the full framing.

**Is there an ISO or a try-it VM?**

No. Install Gentoo first (the
[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)), then add the
overlay. Upstream's ISO is Arch-only, and there is no prebuilt binhost
here — everything compiles from source.

**Where are the docs for themes, hotkeys, plugins, the AI tooling?**

Using the desktop (hotkeys, the AI tooling) is upstream's:
the [official manual](https://omarchy.org/manual/) applies on Gentoo.
The Gentoo side of themes and plugins is documented here —
[Themes](../themes/) and [Plugins](../plugins/): the commands are
upstream's, unmodified.

**Why is some package missing?**

Check the [coverage page](../packages/): it is either shipped, skipped with
a recorded cause, or open in the port queue. Open a pull request if you
want to port it — [Developing](../developing/) explains the flow.

**How do updates work?**

CI republishes the overlay tree as upstream Omarchy changes land (checked
up to every three hours). On your machine: `emaint sync -r omarchy` and
the usual world upgrade — [Install](../install/#keeping-the-overlay-current)
has the commands.

**Does the omarchy command line work?**

The desktop core ports the Omarchy CLI; its package installs go through
`omarchy-pkg-add`, which maps Arch names to Portage atoms at runtime.
[Differences](../differences/) explains.

**What about system updates and the kernel?**

Those remain yours, as on any Gentoo system: Portage owns @world, you own
the kernel and bootloader. The Arch boot stack is deliberately not
ported.
