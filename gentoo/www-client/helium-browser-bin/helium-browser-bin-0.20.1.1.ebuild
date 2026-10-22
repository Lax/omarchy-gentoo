# arch-pkgver: 0.20.1.1
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/helium-browser-bin. The release tarball is a full
# Chromium tree under /opt with a wrapper script; the Arch patches are
# carried in files/ - 0001 is adapted in one string only: the wrapper's
# distro tag says Gentoo, which is the patch's own stated purpose ("Replace
# when packaging").
#
# makepkg verifies the release signature (validpgpkeys + the .asc source);
# the ebuild relies on the CI-generated Manifest digesting the tarball and
# the .asc instead - no gpg keyserver round-trip behind the site proxy.
EAPI=8

inherit desktop

DESCRIPTION="Private, fast, and honest web browser based on Chromium (binary release)"
HOMEPAGE="https://github.com/imputnet/helium-linux"
SRC_URI="
	amd64? ( https://github.com/imputnet/helium-linux/releases/download/${PV}/helium-${PV}-x86_64_linux.tar.xz
		-> ${P}-x86_64_linux.tar.xz )
	arm64? ( https://github.com/imputnet/helium-linux/releases/download/${PV}/helium-${PV}-arm64_linux.tar.xz
		-> ${P}-arm64_linux.tar.xz )
	https://raw.githubusercontent.com/imputnet/helium-linux/${PV}/LICENSE.ungoogled_chromium
		-> ${P}-LICENSE.ungoogled_chromium
"

S="${WORKDIR}"

# The bundled LICENSE.ungoogled_chromium covers the ungoogled-chromium
# patches; the tree itself is GPL-3.0/BSD per the upstream recipe.
LICENSE="GPL-3.0 BSD-3-Clause"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libpulse
	media-libs/libva
	media-fonts/liberation-fonts
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/gtk+:3
	x11-libs/libXScrnSaver
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
"

RESTRICT="strip mirror"
QA_PREBUILT="/opt/helium-browser-bin/*"

PATCHES=(
	"${FILESDIR}"/0001-update-wrapper-arch.patch
	"${FILESDIR}"/0002-align-desktop-entry.patch
)

src_unpack() {
	default
	S="${WORKDIR}/helium-${PV}-$([[ ${ARCH} == amd64 ]] && echo x86_64 || echo arm64)_linux"
}

src_install() {
	dodir /opt
	cp -a . "${ED}/opt/${PN}/" || die

	domenu helium.desktop
	insinto /usr/share/pixmaps
	newins product_logo_256.png helium-browser.png
	insinto /usr/share/icons/hicolor/256x256/apps
	newins product_logo_256.png helium-browser.png
	insinto /usr/share/licenses/${PN}
	newins "${DISTDIR}/${P}-LICENSE.ungoogled_chromium" LICENSE.ungoogled_chromium

	dosym ../../opt/${PN}/helium-wrapper /usr/bin/helium-browser
}

pkg_postinst() {
	elog "Optional WebRTC desktop sharing under Wayland: media-video/pipewire"
	elog "Optional password storage on GNOME/Xfce: gnome-base/gnome-keyring"
	elog "Optional KDE wallet support: kde-frameworks/kwallet"
	elog "Optional battery status API support: sys-power/upower"
	elog "Flags files: /etc/helium-browser-flags.conf and"
	elog "~/.config/helium-browser-flags.conf (one flag per line), or"
	elog "the HELIUM_USER_FLAGS environment variable."
}
