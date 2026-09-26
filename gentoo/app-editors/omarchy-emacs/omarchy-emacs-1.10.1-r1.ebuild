# arch-pkgver: 1.10.1
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: app-editors/omarchy-emacs moved to omarchy/omarchy-emacs. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy/omarchy-emacs"
HOMEPAGE="https://github.com/scottjones/omarchy-emacs"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~omarchy/omarchy-emacs-1.10.1"

pkg_postinst() {
	elog "app-editors/omarchy-emacs has moved to omarchy/omarchy-emacs; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy/omarchy-emacs && emerge --deselect app-editors/omarchy-emacs"
}
