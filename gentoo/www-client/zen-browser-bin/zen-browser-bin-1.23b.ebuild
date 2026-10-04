# arch-pkgver: 1.23b
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/zen-browser-bin. The distribution/policies.json
# payload disables the app's self-updater: on Gentoo, Portage is the only
# update channel.
EAPI=8

inherit desktop

DESCRIPTION="Zen, a privacy-focused, feature packed Firefox-based web browser"
HOMEPAGE="https://github.com/zen-browser/desktop"
SRC_URI="
	amd64? ( https://github.com/zen-browser/desktop/releases/download/${PV}/zen.linux-x86_64.tar.xz -> ${P}-amd64.tar.xz )
	arm64? ( https://github.com/zen-browser/desktop/releases/download/${PV}/zen.linux-aarch64.tar.xz -> ${P}-arm64.tar.xz )
"

S="${WORKDIR}/zen"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Arch's ttf-font virtual -> guarantee one real TTF font provider.
RDEPEND="
	dev-libs/dbus-glib
	dev-libs/nss
	media-video/ffmpeg
	sys-apps/systemd
	x11-libs/gtk+:3
	x11-libs/libXt
	x11-misc/shared-mime-info
	media-fonts/liberation-fonts
"
RESTRICT="strip mirror"

src_install() {
	dodir /opt
	cp -a . "${ED}/opt/${PN}/" || die

	newbin "${FILESDIR}"/zen-browser.sh zen-browser
	domenu "${FILESDIR}"/zen.desktop

	# Icons: symlink the tarball's per-size default icons into hicolor.
	local resolution
	for resolution in 16x16 32x32 48x48 64x64 128x128; do
		dosym -r "/opt/${PN}/browser/chrome/icons/default/default${resolution/x*/}.png" \
			/usr/share/icons/hicolor/${resolution}/apps/zen-browser.png
	done

	# Use system-provided dictionaries (Arch: hunspell/hyphen packages).
	dosym -r /usr/share/hunspell /opt/${PN}/dictionaries
	dosym -r /usr/share/hyphen /opt/${PN}/hyphenation

	# Use system certificates (dev-libs/nss installs libnssckbi.so into
	# /usr/lib64 on both split- and merged-usr amd64/arm64 profiles).
	dosym -r /usr/lib64/libnssckbi.so /opt/${PN}/libnssckbi.so

	# Disable update checks (managed by Portage).
	insinto /opt/${PN}/distribution
	doins "${FILESDIR}"/policies.json
}

pkg_postinst() {
	elog "Optional WiFi-based location detection: net-misc/networkmanager"
	elog "Optional notification integration: x11-libs/libnotify"
	elog "Optional audio support: media-libs/libpulse"
	elog "Optional text-to-speech: app-accessibility/speech-dispatcher"
	elog "Optional spell checking: an English hunspell dictionary"
}
