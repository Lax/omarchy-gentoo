# arch-pkgver: 0.2.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: media-gfx/omarchy-billboard-generator moved to omarchy-extra/omarchy-billboard-generator. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy-extra/omarchy-billboard-generator"
HOMEPAGE="https://github.com/llstrk/omarchy-billboard-generator"

LICENSE="MIT Apache-2.0 0BSD OFL-1.1 all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~omarchy-extra/omarchy-billboard-generator-0.2.0"

pkg_postinst() {
	elog "media-gfx/omarchy-billboard-generator has moved to omarchy-extra/omarchy-billboard-generator; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy-extra/omarchy-billboard-generator && emerge --deselect media-gfx/omarchy-billboard-generator"
}
