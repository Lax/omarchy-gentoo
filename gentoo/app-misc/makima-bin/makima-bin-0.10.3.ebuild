# arch-pkgver: 0.10.3
# Ported from pkgbuilds/makima-bin. Upstream's unit is a system unit with a
# build-time $USER baked in; the remapping daemon is per-user (config in
# ~/.config/makima), so it ships here as a user unit instead.
EAPI=8

inherit systemd udev

DESCRIPTION="Linux daemon to remap and create macros for keyboards, mice and controllers"
HOMEPAGE="https://github.com/cyber-sushi/makima"
SRC_URI="https://github.com/cyber-sushi/makima/releases/download/v${PV}/makima -> ${P}.bin"

S="${WORKDIR}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip mirror"
QA_PREBUILT="/usr/bin/makima"

src_install() {
	newbin "${P}.bin" makima
	insinto /usr/share/licenses/${PF}
	doins "${FILESDIR}"/LICENSE

	insinto /usr/lib/udev/rules.d
	newins "${FILESDIR}"/50-makima.rules 50-makima.rules
	insinto /usr/lib/modules-load.d
	newins "${FILESDIR}"/uinput.conf uinput.conf
	systemd_douserunit "${FILESDIR}"/makima.service
}

pkg_postinst() {
	udev_reload
	elog "Load the uinput module once (or reboot): modprobe uinput"
	elog "Run the daemon per user with:"
	elog "  systemctl --user enable --now makima.service"
}
