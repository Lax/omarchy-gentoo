# arch-pkgver: 20230616.r62
# Ported from pkgbuilds/ttf-ia-writer. Sources are individual TTFs pinned to
# two upstream commits: current iA-Fonts, plus the retired Duospace family at
# the last commit that shipped it.
EAPI=8

DESCRIPTION="Subset of the fonts provided by iA Writer"
HOMEPAGE="https://github.com/iaolo/iA-Fonts"
_BASE="https://github.com/iaolo/iA-Fonts/raw/f32c04c3058a75d7ce28919ce70fe8800817491b"
_LEGACY="https://github.com/iaolo/iA-Fonts/raw/b337fe1a4c93026268f70e4b2678371f3e89e2ce"
SRC_URI="
	${_BASE}/iA%20Writer%20Mono/Static/iAWriterMonoS-Bold.ttf
	${_BASE}/iA%20Writer%20Mono/Static/iAWriterMonoS-BoldItalic.ttf
	${_BASE}/iA%20Writer%20Mono/Static/iAWriterMonoS-Italic.ttf
	${_BASE}/iA%20Writer%20Mono/Static/iAWriterMonoS-Regular.ttf
	${_BASE}/iA%20Writer%20Quattro/Static/iAWriterQuattroS-Bold.ttf
	${_BASE}/iA%20Writer%20Quattro/Static/iAWriterQuattroS-BoldItalic.ttf
	${_BASE}/iA%20Writer%20Quattro/Static/iAWriterQuattroS-Italic.ttf
	${_BASE}/iA%20Writer%20Quattro/Static/iAWriterQuattroS-Regular.ttf
	${_BASE}/iA%20Writer%20Duo/Static/iAWriterDuoS-Bold.ttf
	${_BASE}/iA%20Writer%20Duo/Static/iAWriterDuoS-BoldItalic.ttf
	${_BASE}/iA%20Writer%20Duo/Static/iAWriterDuoS-Italic.ttf
	${_BASE}/iA%20Writer%20Duo/Static/iAWriterDuoS-Regular.ttf
	${_LEGACY}/iA%20Writer%20Duospace/TTF%20(PC)/iAWriterDuospace-Bold.ttf
	${_LEGACY}/iA%20Writer%20Duospace/TTF%20(PC)/iAWriterDuospace-BoldItalic.ttf
	${_LEGACY}/iA%20Writer%20Duospace/TTF%20(PC)/iAWriterDuospace-Italic.ttf
	${_LEGACY}/iA%20Writer%20Duospace/TTF%20(PC)/iAWriterDuospace-Regular.ttf
"

S="${WORKDIR}"
# pkgver is the Arch scheme <upstream-date>.r<commit-count of the pin>
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_install() {
	insinto /usr/share/fonts/ia-writer
	# Explicit names: globs over DISTDIR are flagged by pkgcheck.
	local family style name
	for family in MonoS QuattroS DuoS; do
		for style in Bold BoldItalic Italic Regular; do
			doins "${DISTDIR}/iAWriter${family}-${style}.ttf"
		done
	done
	for style in Bold BoldItalic Italic Regular; do
		doins "${DISTDIR}/iAWriterDuospace-${style}.ttf"
	done
}
