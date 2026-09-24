# arch-pkgver: 0.3.3
# Ported from pkgbuilds/once-bin.
EAPI=8

inherit systemd

DESCRIPTION="CLI/TUI for installing and managing self-hosted web applications"
HOMEPAGE="https://github.com/basecamp/once"
SRC_URI="
	amd64? ( ${HOMEPAGE}/releases/download/v${PV}/once-linux-amd64 -> ${P}-amd64 )
	arm64? ( ${HOMEPAGE}/releases/download/v${PV}/once-linux-arm64 -> ${P}-arm64 )
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="app-containers/docker"

RESTRICT="strip mirror"
QA_PREBUILT="/usr/bin/once"

src_install() {
	newbin "${P}-${ARCH}" once
	insinto /usr/share/licenses/${PF}
	doins "${FILESDIR}"/MIT-LICENSE
	# The .install script only points at the unit and restarts it on upgrade;
	# portage leaves service state to the admin, so the elog carries that.
	systemd_dounit "${FILESDIR}"/once-background.service
}

pkg_postinst() {
	elog "Enable the background service with:"
	elog "  systemctl enable --now once-background.service"
}
