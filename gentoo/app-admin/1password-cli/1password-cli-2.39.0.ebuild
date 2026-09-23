# arch-pkgver: 2.39.0
# Ported from pkgbuilds/1password-cli. Upstream ships a PGP signature inside
# the zip; on Gentoo the Manifest covers the archive's integrity.
EAPI=8

DESCRIPTION="1Password command line tool"
HOMEPAGE="https://developer.1password.com/docs/cli/"
SRC_URI="
	amd64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_amd64_v${PV}.zip )
	arm64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_arm64_v${PV}.zip )
"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The zip is unpacked by unpack().
BDEPEND="app-arch/unzip"
RESTRICT="strip mirror"

src_install() {
	dobin op
}
