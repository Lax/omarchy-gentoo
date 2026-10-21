# arch-pkgver: 7.9
# Ported from pkgbuilds/maplemono-nf-cn. Upstream publishes the zip under one
# unversioned URL; the SRC_URI renames it per-PV so the Manifest digest stays
# bound to the release the PV names.
EAPI=8

DESCRIPTION="Maple Mono monospace font with Nerd Font icons and Chinese glyphs (hinted)"
HOMEPAGE="https://github.com/subframe7536/maple-font"
SRC_URI="https://github.com/subframe7536/maple-font/releases/download/v${PV}/MapleMono-NF-CN.zip -> ${P}.zip"

S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"

src_install() {
	insinto /usr/share/fonts/${PN}
	# Globs over ${WORKDIR} are fine; over ${DISTDIR} pkgcheck objects.
	doins MapleMono-NF-CN-*.ttf
	insinto /usr/share/licenses/${PN}
	doins LICENSE.txt
}
