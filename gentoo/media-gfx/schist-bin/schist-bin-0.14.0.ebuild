# arch-pkgver: 0.14.0
# Ported from pkgbuilds/schist-bin. The release asset is a pacman-format
# payload assembled by upstream's packaging/linux/packages.sh from CI; this
# re-wraps its usr/ tree, so RDEPEND has to stay in step with that script.
EAPI=8

DESCRIPTION="Layered image editor with PSD and Affinity support (binary release)"
HOMEPAGE="https://github.com/Infrawrench/schist"
# _relver is upstream's own package release, embedded in the asset name; it
# only moves when the packaging changes under a version that already shipped.
_RELVER=1
SRC_URI="
	amd64? ( ${HOMEPAGE}/releases/download/v${PV}/schist-${PV}-${_RELVER}-x86_64.pkg.tar.zst -> ${P}-x86_64.pkg.tar.zst )
	arm64? ( ${HOMEPAGE}/releases/download/v${PV}/schist-${PV}-${_RELVER}-aarch64.pkg.tar.zst -> ${P}-arm64.pkg.tar.zst )
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The payload is dlopen'd against these (fontconfig/wayland/vulkan-loader
# look optional to namcap; they are not). A Vulkan ICD itself is a per-machine
# choice — see the elog.
RDEPEND="
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/freetype
	media-libs/vulkan-loader
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-themes/hicolor-icon-theme
	x11-libs/libxkbcommon[X]
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
	# The payload keeps the licence under the upstream pkgname.
	mv "${ED}"/usr/share/licenses/schist "${ED}"/usr/share/licenses/${PF} || die
}

pkg_postinst() {
	elog "A Vulkan ICD is needed to draw (e.g. media-libs/vulkan-lavapipe for"
	elog "software rendering); media-libs/libheif adds HEIC import."
}
