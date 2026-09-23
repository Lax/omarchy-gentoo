# arch-pkgver: 0.15.0
# Ported from pkgbuilds/python-terminaltexteffects. Unlike the Arch package,
# which deletes the console script, the tte CLI is kept: nothing on Gentoo
# conflicts with it.
EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..15} )
inherit distutils-r1

MY_PN=terminaltexteffects
DESCRIPTION="Visual effects engine for terminal text (library and tte CLI)"
HOMEPAGE="https://github.com/ChrisBuilds/terminaltexteffects"
SRC_URI="https://github.com/ChrisBuilds/${MY_PN}/archive/release-${PV}.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/${MY_PN}-release-${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
