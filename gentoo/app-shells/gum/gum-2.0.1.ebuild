# arch-pkgver: 2.0.1
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A tool for glamorous shell scripts"
HOMEPAGE="https://github.com/charmbracelet/gum"
SRC_URI="https://github.com/charmbracelet/gum/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Lax/omarchy-overlay/releases/download/distfiles/${P}-deps.tar.xz"

LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=dev-lang/go-1.25"

src_unpack() {
	default
	pushd "${S}" >/dev/null || die
	sed -i -e 's/^go 1\.26\.7$/go 1.25.8/' go.mod || die
	ego mod verify
	popd >/dev/null || die
}

src_compile() {
	ego build -trimpath -ldflags "-s -w -X main.Version=v${PV}" -o ${PN} .
}

src_install() {
	dobin ${PN}
	einstalldocs
}
