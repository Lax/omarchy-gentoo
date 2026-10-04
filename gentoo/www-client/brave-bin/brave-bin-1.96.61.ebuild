# arch-pkgver: 1.96.61
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/brave-bin. Upstream carries epoch=1, which has no
# Gentoo equivalent for a fresh package - the epoch is dropped here.
EAPI=8

inherit desktop

DESCRIPTION="Web browser that blocks ads and trackers by default (binary release)"
HOMEPAGE="https://brave.com"
SRC_URI="
	amd64? ( https://github.com/brave/brave-browser/releases/download/v${PV}/brave-browser-${PV}-linux-amd64.zip
		-> ${P}-amd64.zip )
	arm64? ( https://github.com/brave/brave-browser/releases/download/v${PV}/brave-browser-${PV}-linux-arm64.zip
		-> ${P}-arm64.zip )
"

S="${WORKDIR}"

# The bundled LICENSE covers the MPL-2.0 browser code and the BSD-licensed
# components; the recipe's custom:chromium clause rides along inside it.
LICENSE="MPL-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Arch's ttf-font virtual -> guarantee one real TTF font provider.
RDEPEND="
	dev-libs/nss
	media-libs/alsa-lib
	x11-libs/gtk+:3
	x11-libs/libXScrnSaver
	media-fonts/liberation-fonts
"
BDEPEND="app-arch/unzip"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	# The zip holds the browser tree at its top level (no wrapping directory).
	unzip -qo "${DISTDIR}/${P}-$([[ ${ARCH} == amd64 ]] && echo amd64 || echo arm64).zip" || die
}

src_install() {
	dodir /opt
	cp -a . "${ED}/opt/${PN}/" || die

	# Allow firejail users to get the suid sandbox working.
	fperms 4755 /opt/${PN}/chrome-sandbox

	newbin "${FILESDIR}"/brave-bin.sh brave
	domenu "${FILESDIR}"/brave-browser.desktop

	insinto /usr/share/licenses/${PN}
	doins LICENSE

	local resolution
	for resolution in 16x16 24x24 32x32 48x48 64x64 128x128 256x256; do
		insinto /usr/share/icons/hicolor/${resolution}/apps
		doins "product_logo_${resolution/x*/}.png"
	done
}

pkg_postinst() {
	elog "Optional printer support: net-print/cups"
	elog "Optional native notifications: x11-libs/libnotify"
	elog "Optional GNOME keyring support: gnome-base/gnome-keyring"
	elog "User flags file: ~/.config/brave-flags.conf (one flag per line)"
}
