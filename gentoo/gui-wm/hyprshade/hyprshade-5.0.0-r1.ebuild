# arch-pkgver: 5.0.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: gui-wm/hyprshade moved to gui-apps/hyprshade. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to gui-apps/hyprshade"
HOMEPAGE="https://github.com/loqusion/hyprshade"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~gui-apps/hyprshade-5.0.0"

pkg_postinst() {
	elog "gui-wm/hyprshade has moved to gui-apps/hyprshade; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace gui-apps/hyprshade && emerge --deselect gui-wm/hyprshade"
}
