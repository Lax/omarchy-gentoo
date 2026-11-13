---
title: Plugins
desc: Omarchy shell plugins on Gentoo — upstream's commands, unmodified: add, enable, list, update, remove.
---
## The commands are the same

Shell plugins are upstream's mechanism, unchanged on Gentoo. A plugin is
a git repo with a `manifest.json` and QML entry points, cloned into
`~/.config/omarchy/plugins/` and loaded by the Omarchy shell:

```bash
omarchy plugin list                                    # installed + built-in
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
omarchy plugin enable omarchy.tailscale
omarchy plugin update acme.weather                     # or all: omarchy plugin update
omarchy plugin remove acme.weather
omarchy plugin validate ./my-plugin                    # before installing
```

The catalog lives at [plugins.omarchy.org](https://plugins.omarchy.org).
No package manager is involved anywhere in that flow — installing a
plugin never touches Portage, and none of it needs sudo.

## Security

Upstream's warning applies verbatim: plugins run as arbitrary,
unsandboxed code inside the long-lived shell process, with your user's
privileges. Read a plugin's code (or trust its author) before enabling
it.

## Not this word: elephant providers

The launcher stack has its own "plugins" — the elephant search daemon's
providers (calculator, clipboard, files, unicode, ...). Those are
ordinary Portage packages: one merged ebuild ships the daemon and every
provider, installed and updated with the rest of the overlay (the
[coverage page](../packages/) lists them). Shell plugins are the
git-installed, manifest-carrying kind this page is about; the two only
share the word.

Authoring plugins — the manifest schema, kinds, entry points — is
upstream's
[plugin guide](https://github.com/omacom/omarchy/blob/v4.5.0/manual/32-shell-plugins.md)
and applies here unchanged.
