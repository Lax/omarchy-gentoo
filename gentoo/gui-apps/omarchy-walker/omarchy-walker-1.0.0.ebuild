# arch-pkgver: 1.0.0
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

EAPI=8

DESCRIPTION="Meta package for walker with Elephant providers for Omarchy"
HOMEPAGE="https://omarchy.org"
# Gentoo consolidation: upstream splits the elephant providers into a dozen
# pacman packages (partial upgrades); gui-apps/elephant here ships them all,
# so the meta reduces to the launcher pair.

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	gui-apps/elephant
	gui-apps/walker
"
