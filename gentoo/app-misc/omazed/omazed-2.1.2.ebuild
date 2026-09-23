# arch-pkgver: 2.1.2
# Ported from pkgbuilds/omaged.
EAPI=8

DESCRIPTION="Live theme switching for Zed in Omarchy"
HOMEPAGE="https://github.com/aps6/omazed"
SRC_URI="https://github.com/aps6/omazed/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

RDEPEND="app-shells/bash"

S="${WORKDIR}/${P}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_install() {
	dobin omazed omazed-generator.sh
	# Template consumed by the generator at runtime; installed next to it.
	insinto /usr/bin
	doins omazed-theme.tpl
	fperms 644 /usr/bin/omazed-theme.tpl

	dodoc README.md
}

pkg_postinst() {
	elog "Run 'omazed setup' to complete installation:"
	elog "- sets up Omarchy hook integration (or a systemd fallback)"
	elog "- applies the current theme to Zed once"
	elog "The generated ~/.config/zed/themes/omazed.json is preserved on removal."
}
