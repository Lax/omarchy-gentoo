# arch-pkgver: 4.32.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/aether. Upstream's own recipe ships the release
# binaries (source builds stay a packaging exercise in webkit; the tags
# carry amd64/arm64 builds) and picks the desktop entries, icons and
# README out of the source tarball - mirrored here one for one. The
# -> renames key DISTDIR to the version, since the release assets name
# no version.
EAPI=8

inherit desktop xdg

DESCRIPTION="Desktop theming app: extract colors from wallpapers into cohesive themes (Omarchy application)"
HOMEPAGE="https://github.com/omacom/aether"
SRC_URI="
	https://github.com/omacom/aether/archive/refs/tags/v${PV}.tar.gz -> aether-${PV}.tar.gz
	amd64? ( https://github.com/omacom/aether/releases/download/v${PV}/aether-linux-amd64 -> aether-${PV}-linux-amd64 )
	arm64? ( https://github.com/omacom/aether/releases/download/v${PV}/aether-linux-arm64 -> aether-${PV}-linux-arm64 )
"

S="${WORKDIR}/aether-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream depends: webkit2gtk-4.1, gtk3.
RDEPEND="
	net-libs/webkit-gtk:4.1
	x11-libs/gtk+:3
"

RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/aether"

src_install() {
	# ${ARCH} (amd64/arm64) matches the release asset suffix exactly.
	newbin "${DISTDIR}/aether-${PV}-linux-${ARCH}" aether

	domenu build/linux/aether.desktop li.oever.aether.url-handler.desktop
	doicon icon.png
	newicon -s 512 assets/aether-icon-512.png aether.png

	einstalldocs
}
