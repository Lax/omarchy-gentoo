---
title: Themes
desc: Omarchy themes on Gentoo — the same commands as upstream, the stock set included, and exactly what this overlay adds.
---
## The commands are the same

Theme switching on Gentoo is upstream's machinery, unmodified: the
selector lives in the shell (`Super + Ctrl + T`, or _Appearance > Theme_
in the menu), and installing a third-party theme is the same command as
on Arch:

```bash
omarchy theme install https://github.com/<author>/omarchy-<name>-theme
```

Upstream's theme flow is git clones and file operations — no pacman, no
sudo — so nothing in it needed porting. A switch regenerates the themed
app templates, retints the whole shell, and runs the `theme-set` hooks
exactly as upstream's manual describes.

## What ships with the overlay

- The stock theme set, installed by the omarchy ebuild under
  `/usr/share/omarchy/themes`.
- The background intros for every stock theme (`omarchy-themes-intros`).
- The SDDM login theme and the unlock-screen styling
  (omarchy-settings).
- The icon sets themes reference through their `icons.theme` file —
  `x11-themes/yaru-icon-theme`, the icon split of ubuntu/yaru (Gentoo
  removed the package in its 2026 tree; the overlay ports it again).
- Aether, the theme editor GUI the manual names —
  `x11-themes/aether-bin`, built from upstream's release binaries.

## Known gaps

A few in-house helpers are still pending ports (in the porting backlog,
P3): the `owe` wallpaper engine, the `omarchy-hyprland-titlebars` Hyprland
plugin, and the `signed`/`gliff`/`hype`/`monologue` apps. Colors, terminal
and shell theming switch cleanly without them; wallpaper handling falls
back until `owe` lands.

Authoring your own theme — the `colors.toml` format, the
`~/.config/omarchy/themed/*.tpl` templates, sharing under
`omarchy-<name>-theme` — is upstream's
[guide](https://github.com/omacom/omarchy/blob/v4.5.0/manual/43-making-your-own-theme.md)
and applies here unchanged. The community gallery lives at
[omarchy.org/themes](https://omarchy.org/themes/).
