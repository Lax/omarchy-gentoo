# arch-pkgver: 2.22.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

EAPI=8

inherit go-module

DESCRIPTION="General purpose datasource and executor (Omarchy launcher backend)"
HOMEPAGE="https://github.com/abenz1267/elephant"
# Gentoo consolidation: upstream omarchy-pkgs splits the providers into a
# dozen elephant-* pacman packages for partial upgrades; a source overlay
# rebuilds everything together, so one ebuild ships the daemon and every
# provider plugin from the same pinned source.
SRC_URI="https://github.com/abenz1267/elephant/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Lax/omarchy-overlay/releases/download/distfiles/${P}-deps.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25"

src_unpack() {
	default
	pushd "${S}" >/dev/null || die
	ego mod verify
	popd >/dev/null || die
}

src_compile() {
	pushd cmd/elephant >/dev/null || die
	ego build -ldflags="-s -w" -buildvcs=false -trimpath -o elephant .
	popd >/dev/null || die

	local p
	for p in internal/providers/*/; do
		p=${p%/}
		pushd "${p}" >/dev/null || die
		ego build -ldflags="-s -w" -buildvcs=false -trimpath \
			-buildmode=plugin -o "${p##*/}.so" .
		popd >/dev/null || die
	done
}

src_install() {
	dobin cmd/elephant/elephant
	# Plugin lookup path upstream (walker discovers providers here).
	exeinto /usr/lib/elephant
	doexe internal/providers/*/*.so
	dodoc README.md
}
