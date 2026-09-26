# arch-pkgver: 1.5.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: app-shells/omarchy-fish moved to omarchy/omarchy-fish. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy/omarchy-fish"
HOMEPAGE="https://github.com/omacom-io/omarchy-fish"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~omarchy/omarchy-fish-1.5.0"

pkg_postinst() {
	elog "app-shells/omarchy-fish has moved to omarchy/omarchy-fish; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy/omarchy-fish && emerge --deselect app-shells/omarchy-fish"
}
