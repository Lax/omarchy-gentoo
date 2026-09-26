# arch-pkgver: 0.1.0
# Ported from pkgbuilds/omarchy-audio-tuner. The tools call each other by
# relative path, so the tree is installed intact under /usr/share and a single
# symlink puts one command on PATH; generated artifacts go to the user's
# ~/.cache, never back into this tree.
EAPI=8

DESCRIPTION="Tools for authoring Omarchy laptop speaker tunings (Omarchy application)"
HOMEPAGE="https://github.com/omacom-io/omarchy-audio-tuner"
SRC_URI="https://github.com/omacom-io/omarchy-audio-tuner/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# pactl comes from media-libs/libpulse; mpv plays the probe, ffmpeg captures
# and analyses it, and lsp-plugins supplies the lookahead limiter a generated
# chain ends in. Scripts run under the system python (python-single-r1).
PYTHON_COMPAT=( python3_{11..15} )
inherit python-single-r1

RDEPEND="
	app-shells/bash
	media-libs/libpulse
	media-libs/lsp-plugins
	media-video/ffmpeg
	media-video/mpv
	${PYTHON_DEPS}
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	insinto /usr/share/${PN}
	doins -r measure fit generate compare
	exeinto /usr/share/${PN}
	doexe omarchy-audio-tuner

	dosym -r /usr/share/${PN}/omarchy-audio-tuner /usr/bin/${PN}

	dodoc README.md LICENSE
}
