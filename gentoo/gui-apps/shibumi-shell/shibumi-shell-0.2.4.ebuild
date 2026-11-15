# arch-pkgver: 0.2.4
# Ported from pkgbuilds/shibumi-shell.
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the MIT license

EAPI=8

DESCRIPTION="Transactional Shibumi desktop shell plugins for Omarchy Quattro"
HOMEPAGE="https://github.com/HANCORE-linux/Shibumi-Shell"
SRC_URI="https://github.com/HANCORE-linux/Shibumi-Shell/releases/download/v${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
# arch=(any) normally maps to ~amd64 ~arm64, but the hard omarchy dep only
# keywords ~amd64, so arm64 would be unsolvable (pkgcheck NonsolvableDeps).
KEYWORDS="~amd64"

RDEPEND="
	dev-lang/python
	dev-python/dbus-python
	dev-libs/glib
	gui-apps/quickshell
	gui-apps/wl-clipboard
	media-fonts/adwaita-fonts
	media-fonts/jetbrains-mono-nerd-basic
	media-fonts/material-symbols-variable
	media-fonts/noto-cjk
	net-misc/curl
	net-misc/iputils
	net-misc/networkmanager
	app-misc/jq
	omarchy/omarchy
	sys-apps/systemd
	sys-power/power-profiles-daemon
	sys-power/upower
	x11-libs/libnotify
	x11-misc/xdg-utils
"

# The Arch optdepends are optional feature boosters; on Gentoo they stay
# unversioned wishes, named by the postinst.
pkg_postinst() {
	elog "Optional feature support (install as needed):"
	elog "  media-sound/cava              - live media spectrum"
	elog "  media-video/ffmpegthumbnailer - video picker thumbnails"
	elog "  media-gfx/imagemagick         - additional media thumbnails"
	elog "  sys-process/btop              - battery panel system monitor action"
	elog "  x11-drivers/nvidia-drivers    - NVIDIA GPU telemetry"
	elog "  dev-vcs/git                   - source-checkout diagnostics and migration"
}

src_install() {
	insinto /usr/share/${PN}
	doins -r hancore.shibumi.*
	# Upstream copies the plugin trees with cp -a; portage's doins loses the
	# executable bits the plugins' runtime helpers (agents-update, the
	# compat shims) need, so restore them from the source tree.
	local f
	while read -r f; do
		fperms +x "usr/share/${PN}/${f}"
	done < <(find hancore.shibumi.* -type f -perm -111)

	insinto /usr/share/${PN}/contracts
	# Only the plugin-suite contracts travel: the baselines/ tree is
	# upstream's own release-verification data, not runtime payload.
	doins contracts/plugin-suite-v1.json contracts/host-facade-v1.json \
		contracts/package-runtime-v1.json contracts/backend-boundary-v1.json \
		contracts/lifecycle-predecessors-v1.json
	exeinto /usr/share/${PN}/scripts
	doexe scripts/shibumi-suite
	insinto /usr/share/${PN}/scripts
	doins -r scripts/shibumi_suite
	doins VERSION
	newins packaging/package-metadata.json PACKAGE-METADATA.json

	dobin packaging/shibumi-shell

	dodoc README.md docs/install.md
}
