# arch-pkgver: 148.0.7778.96
# Ported from pkgbuilds/omarchy-chromium-bin. The release asset is a
# pacman-format payload; this re-wraps its usr/ tree.
EAPI=8

DESCRIPTION="A web browser built for speed, simplicity, and security, with patches for Omarchy (custom build)"
HOMEPAGE="https://www.chromium.org/Home"
# _build is upstream's own package release, embedded in the asset name.
_BUILD=21
SRC_URI="
	amd64? ( https://github.com/omacom-io/omarchy-chromium/releases/download/v${PV}-${_BUILD}/omarchy-chromium-${PV}-${_BUILD}-x86_64.pkg.tar.zst -> ${P}-x86_64.pkg.tar.zst )
	arm64? ( https://github.com/omacom-io/omarchy-chromium/releases/download/v${PV}-${_BUILD}/omarchy-chromium-${PV}-${_BUILD}-aarch64.pkg.tar.zst -> ${P}-arm64.pkg.tar.zst )
"

S="${WORKDIR}"
# Upstream uses BSD-3-Clause; BSD is this tree's token for it.
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/libgcrypt
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libpulse
	media-libs/libva
	net-print/cups
	sys-apps/dbus
	sys-apps/pciutils
	sys-apps/systemd
	dev-libs/libffi
	media-fonts/liberation-fonts
	dev-util/desktop-file-utils
	x11-themes/hicolor-icon-theme
	x11-libs/gtk+:3
	x11-libs/libXScrnSaver
	dev-libs/nss
	x11-misc/xdg-utils
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${A}" || die
}

src_install() {
	cp -a "${S}"/usr "${ED}"/ || die
}
