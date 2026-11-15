# arch-pkgver: 2026.10.27
# Ported from pkgbuilds/omarchy-amiga-screensaver. The recipe pins the demo
# set to one upstream commit; the distfile is that commit's tree.
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Amiga demos for the Omarchy screensaver"
HOMEPAGE="https://github.com/omacom/omarchy-amiga-screensaver"
_COMMIT=f5d2d0869d1b1b5b1f3af61d68b9be7fabbb6eec
SRC_URI="https://github.com/omacom/omarchy-amiga-screensaver/archive/${_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${_COMMIT}"

# Upstream marks the package license=('custom') and ships its README as the
# license text: the demos belong to the groups that made them and are
# included as the scene released them (authorship credited in the README),
# with no explicit license grant - hence the token.
LICENSE="all-rights-reserved"
SLOT="0"
# arch=(any) normally maps to ~amd64 ~arm64, but the hard fs-uae dep only
# keywords ~amd64, so arm64 would be unsolvable (pkgcheck NonsolvableDeps).
KEYWORDS="~amd64"

# The demos are FS-UAE configurations and disk images; the emulator plays
# them off its built-in AROS Kickstart, so no ROM package is needed.
RDEPEND="app-emulation/fs-uae"

# Same pairing as the tree's binary repackages (1password, dropbox): no
# explicit license grant, so the distfile does not mirror.
RESTRICT="mirror"

src_install() {
	insinto /usr/share/${PN}
	doins -r demos
	insinto /usr/share/licenses/${PN}
	doins README.md
}
