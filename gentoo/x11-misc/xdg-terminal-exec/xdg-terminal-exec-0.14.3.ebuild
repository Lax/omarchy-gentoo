# arch-pkgver: 0.14.3
# Ported from pkgbuilds/xdg-terminal-exec (upstream tarball ships the man
# page as scdoc source; the Makefile renders it).
EAPI=8

DESCRIPTION="Proposed standard to launching desktop apps with Terminal=true"
HOMEPAGE="https://gitlab.freedesktop.org/Vladimir-csp/xdg-terminal-exec"
SRC_URI="https://gitlab.freedesktop.org/Vladimir-csp/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz"

S="${WORKDIR}/${PN}-v${PV}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-text/scdoc"

src_compile() {
	emake
}

src_install() {
	emake prefix="${ED}/usr" install
}
