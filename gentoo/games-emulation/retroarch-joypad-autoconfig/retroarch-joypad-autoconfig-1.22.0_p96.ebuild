# arch-pkgver: 1.22.0.r96.g0331510
# Ported from pkgbuilds/retroarch-joypad-autoconfig-git (pinned commit as a
# codeload tarball; _p encodes the commit count from Arch's git-describe
# pkgver v1.22.0-96-g0331510). Non-Linux drivers are dropped like Arch does.
EAPI=8

DESCRIPTION="RetroArch joypad autoconfig files"
HOMEPAGE="https://github.com/libretro/retroarch-joypad-autoconfig"
_COMMIT=033151045d378b64e712a92592467800d7924227
SRC_URI="https://github.com/libretro/retroarch-joypad-autoconfig/archive/${_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${_COMMIT}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Data-only package; no runtime dependency: this tree has no RetroArch yet,
# the files are inert until one appears (any overlay works).

src_prepare() {
	default
	rm -r dinput mfi qnx xinput || die
}

src_install() {
	local cfg
	while IFS= read -r cfg; do
		insinto "/usr/share/libretro/autoconfig/${cfg%/*}"
		doins "$cfg"
	done < <(find . -iname '*.cfg' -type f | sed 's|^\./||')

	dodoc README.md retropad_layout.png
}

pkg_postinst() {
	elog "These autoconfig profiles are consumed by RetroArch (not packaged"
	elog "in this tree; install it from an overlay that carries it)."
}
