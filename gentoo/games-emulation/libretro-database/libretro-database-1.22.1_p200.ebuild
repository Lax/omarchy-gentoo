# arch-pkgver: 1.22.1.r200.g9aec589
# Ported from pkgbuilds/libretro-database-git. The Arch recipe pins a git
# commit; here that pin becomes the codeload tarball of the same commit, so
# the content is identical and Manifest-verifiable. _p suffix encodes the
# commit count from Arch's git-describe pkgver (v1.22.1-200-g9aec589).
EAPI=8

DESCRIPTION="RetroArch's cheatcode files, content data files, etc."
HOMEPAGE="https://github.com/libretro/libretro-database"
_COMMIT=9aec58983a73ba4370ba6fd7c1b7d915ec56dda6
SRC_URI="https://github.com/libretro/libretro-database/archive/${_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${_COMMIT}"
LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Data-only package; no runtime dependency: this tree has no RetroArch yet,
# the files are inert until one appears (any overlay works).

src_install() {
	emake DESTDIR="${D}" install
}

pkg_postinst() {
	elog "These data files are consumed by RetroArch (not packaged in this"
	elog "tree; install it from an overlay that carries games-emulation/retroarch)."
}
