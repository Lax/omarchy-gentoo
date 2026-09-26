# arch-pkgver: 4.0.4
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: app-misc/omarchy-settings moved to omarchy/omarchy-settings. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy/omarchy-settings"
HOMEPAGE="https://github.com/omacom/omarchy"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="~omarchy/omarchy-settings-4.0.4"

pkg_postinst() {
	elog "app-misc/omarchy-settings has moved to omarchy/omarchy-settings; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy/omarchy-settings && emerge --deselect app-misc/omarchy-settings"
}
