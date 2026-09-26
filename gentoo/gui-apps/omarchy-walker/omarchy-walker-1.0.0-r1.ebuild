# arch-pkgver: 1.0.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: gui-apps/omarchy-walker moved to omarchy/omarchy-walker. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy/omarchy-walker"
HOMEPAGE="https://omarchy.org"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="~omarchy/omarchy-walker-1.0.0"

pkg_postinst() {
	elog "gui-apps/omarchy-walker has moved to omarchy/omarchy-walker; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy/omarchy-walker && emerge --deselect gui-apps/omarchy-walker"
}
