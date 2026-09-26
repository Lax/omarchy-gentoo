# arch-pkgver: 1.0.2
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: media-sound/omarchy-meeting-recorder-bin moved to omarchy-extra/omarchy-meeting-recorder-bin. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy-extra/omarchy-meeting-recorder-bin"
HOMEPAGE="https://github.com/jankeesvw/omarchy-meeting-recorder"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="~omarchy-extra/omarchy-meeting-recorder-bin-1.0.2"

pkg_postinst() {
	elog "media-sound/omarchy-meeting-recorder-bin has moved to omarchy-extra/omarchy-meeting-recorder-bin; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy-extra/omarchy-meeting-recorder-bin && emerge --deselect media-sound/omarchy-meeting-recorder-bin"
}
