# arch-pkgver: 0.1.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Migration shim: media-sound/omarchy-audio-tuner moved to omarchy-extra/omarchy-audio-tuner. Empty on purpose — it pulls the new
# location so a plain upgrade migrates installed systems. Drop this once
# users have moved over.
EAPI=8

DESCRIPTION="Transitional package - moved to omarchy-extra/omarchy-audio-tuner"
HOMEPAGE="https://github.com/omacom-io/omarchy-audio-tuner"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~omarchy-extra/omarchy-audio-tuner-0.1.0"

pkg_postinst() {
	elog "media-sound/omarchy-audio-tuner has moved to omarchy-extra/omarchy-audio-tuner; this package is an empty transitional"
	elog "shim and can be removed. To update your world file:"
	elog "  emerge --noreplace omarchy-extra/omarchy-audio-tuner && emerge --deselect media-sound/omarchy-audio-tuner"
}
