# arch-pkgver: 148.0.7778.96
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: www-client/omarchy-chromium-bin moved to omarchy/omarchy-chromium-bin. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy/omarchy-chromium-bin"
HOMEPAGE="https://www.chromium.org/Home"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~omarchy/omarchy-chromium-bin-148.0.7778.96"

pkg_postinst() {
	elog "www-client/omarchy-chromium-bin has moved to omarchy/omarchy-chromium-bin; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy/omarchy-chromium-bin && emerge --deselect www-client/omarchy-chromium-bin"
}
