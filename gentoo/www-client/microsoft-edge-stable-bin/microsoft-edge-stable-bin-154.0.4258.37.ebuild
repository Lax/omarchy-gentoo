# arch-pkgver: 154.0.4258.37
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/microsoft-edge-stable-bin: extract the vendor .deb
# and install its usr/ and opt/ trees; never run the maintainer scripts.
EAPI=8

DESCRIPTION="Microsoft Edge web browser (stable channel, binary release)"
HOMEPAGE="https://www.microsoftedgeinsider.com/en-us/download"
# The pool URL embeds the Debian revision (-1); stable has stayed at 1 for
# every release, but bump it by hand if Microsoft revs it.
SRC_URI="
	amd64? ( https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${PV}-1_amd64.deb -> ${P}.deb )
"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/libxml2
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libXtst
"
# libarchive reads the .deb; imagemagick renders the icon sizes the deb
# omits (256/24 are the only shipped sizes).
BDEPEND="app-arch/libarchive media-gfx/imagemagick"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.xz || die
	bsdtar -xf data.tar.xz --no-same-owner || die
	rm -f data.tar.xz || die
}

src_install() {
	# 256 and 24 are the proper colored icons; render the sizes the deb
	# omits from them (before the tree moves into ${ED}).
	local res
	for res in 128 64 48 32; do
		magick opt/microsoft/msedge/product_logo_256.png -resize ${res}x${res} \
			opt/microsoft/msedge/product_logo_${res}.png || die
	done
	for res in 22 16; do
		magick opt/microsoft/msedge/product_logo_24.png -resize ${res}x${res} \
			opt/microsoft/msedge/product_logo_${res}.png || die
	done

	# The vendor tree lives in usr/ and opt/; data.tar.xz's etc/ (apt repo
	# config, cron keyring job) is deliberately not installed.
	cp -a usr opt "${ED}"/ || die

	# suid sandbox
	fperms 4755 /opt/microsoft/msedge/msedge-sandbox

	for res in 16 24 32 48 64 128 256; do
		insinto /usr/share/icons/hicolor/${res}x${res}/apps
		newins opt/microsoft/msedge/product_logo_${res}.png microsoft-edge.png
	done

	# User flag aware launcher
	newbin "${FILESDIR}"/microsoft-edge-stable.sh microsoft-edge-stable

	# License
	insinto /usr/share/licenses/${PN}
	newins "${FILESDIR}"/microsoft-edge-eula.pdf LICENSE.pdf

	rm -f "${ED}"/opt/microsoft/msedge/product_logo_*.png || die

	# Remove the vendor cron dir left inside opt (the cron.daily side is
	# under etc/, which was never copied).
	rm -r "${ED}/opt/microsoft/msedge/cron" || die
}

pkg_postinst() {
	elog "Custom flags should be put directly in:"
	elog "  ~/.config/microsoft-edge-stable-flags.conf"
	elog "The launcher is called: microsoft-edge-stable"
	elog "Optional WebRTC desktop sharing under Wayland: media-video/pipewire"
	elog "Optional password storage: gnome-base/gnome-keyring"
}
