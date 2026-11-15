# arch-pkgver: 4.0.0_p20261023
# Hand-maintained in the overlay: the Arch recipe (extra/ttf-material-symbols-variable)
# lives outside the omarchy-pkgs submodule, so sync-gentoo keeps this row as a
# harmless "not present" note. Version is upstream's latest variablefont tag plus
# the date the font commit was pinned; the pin is the last commit that touched
# upstream's variablefont/ directory, so the distfiles stay stable.
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the Apache-2.0 license

EAPI=8

DESCRIPTION="Material Design icons by Google - variable fonts"
HOMEPAGE="https://github.com/google/material-design-icons"
_COMMIT=10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7
_BASE="https://github.com/google/material-design-icons/raw/${_COMMIT}/variablefont"
# The bracketed upstream names are URL-escaped and renamed: bracketed DISTDIR
# names glob badly and pkgcheck flags globs anyway.
SRC_URI="
	${_BASE}/MaterialSymbolsOutlined%5BFILL,GRAD,opsz,wght%5D.ttf -> ${P}-outlined.ttf
	${_BASE}/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf -> ${P}-rounded.ttf
	${_BASE}/MaterialSymbolsSharp%5BFILL,GRAD,opsz,wght%5D.ttf -> ${P}-sharp.ttf
"

S="${WORKDIR}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_install() {
	insinto /usr/share/fonts/${PN}
	# Explicit names: globs over DISTDIR are flagged by pkgcheck.
	local v
	for v in outlined rounded sharp; do
		doins "${DISTDIR}/${P}-${v}.ttf"
	done
}
