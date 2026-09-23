# arch-pkgver: 251123
# Ported from pkgbuilds/ufw-docker.
EAPI=8

DESCRIPTION="Fix the Docker and UFW security flaw without disabling iptables"
HOMEPAGE="https://github.com/chaifeng/ufw-docker"
SRC_URI="https://github.com/chaifeng/ufw-docker/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-containers/docker
	net-firewall/ufw
"

src_install() {
	dobin ufw-docker
	dodoc LICENSE
}

pkg_postinst() {
	elog "Run 'ufw-docker install' to update ufw rules (backups of existing"
	elog "rules are made automatically). To restore them, run"
	elog "'ufw-docker uninstall'."
}
