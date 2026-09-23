# arch-pkgver: 5.4.0
# Ported from pkgbuilds/nordvpn-bin. Arch's sysusers line becomes an
# acct-group package; the .install's runtime symlink loop (linking the
# bundled libs into /usr/lib) is done statically at install time instead.
EAPI=8

DESCRIPTION="NordVPN CLI tool for Linux"
HOMEPAGE="https://nordvpn.com/download/linux/"
SRC_URI="https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${PV}_amd64.deb -> ${P}.deb"

S="${WORKDIR}"
# Arch declares GPL3 (the CLI wrapper's license); the bundled nordvpnd and
# libraries in the .deb are proprietary vendor builds.
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="acct-group/nordvpn"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.xz || die
	bsdtar -xf data.tar.xz --no-same-owner || die
}

src_install() {
	mv usr/sbin/nordvpnd usr/bin/ || die
	rm -r etc/init.d || die
	rm -r usr/sbin || die

	keepdir /var/lib/nordvpn/data
	fperms 0750 /var/lib/nordvpn /var/lib/nordvpn/data

	cp -a etc usr var "${ED}"/ || die

	# The deb keeps its private libraries in /usr/lib/nordvpn; nordvpnd
	# expects them resolvable from /usr/lib (the Arch .install links each
	# one at runtime).
	local lib
	for lib in usr/lib/nordvpn/*.so*; do
		[[ -e "${S}/${lib}" ]] || continue
		dosym -r "/usr/lib/nordvpn/${lib##*/}" "/usr/lib/${lib##*/}"
	done
}

pkg_postinst() {
	elog "To enable NordVPN, start the service:"
	elog "  systemctl enable --now nordvpnd"
	elog "Add your user to the nordvpn group (gpasswd -a <user> nordvpn)"
	elog "and re-login for it to take effect."
}
